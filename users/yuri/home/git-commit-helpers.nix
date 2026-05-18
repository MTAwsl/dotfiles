_: {
  flake.modules.users.yuri.home.git-commit-helpers =
    {
      config,
      options,
      pkgs,
      lib,
      ...
    }:
    let
      model = "openai/gpt-5.3-codex-spark";
      agent = "OpenTechnicalWriter";

      hasOacOption = lib.hasAttrByPath [ "programs" "opencode" "oac" "enable" ] options;
      isOpenCodeEnabled = config.programs.opencode.enable or false;
      isOacEnabled = hasOacOption && config.programs.opencode.oac.enable;
      opencodePackage = config.programs.opencode.package or null;

      runtimeInputs =
        with pkgs;
        [
          coreutils
          git
          gnugrep
          gnused
        ]
        ++ lib.optional (opencodePackage != null) opencodePackage;

      gitAiCommit = pkgs.writeShellApplication {
        name = "git-ai-commit";
        inherit runtimeInputs;
        text = ''
          set -euo pipefail

          opencode_model=${lib.escapeShellArg model}
          opencode_agent=${lib.escapeShellArg agent}
          oac_enabled=${lib.boolToString isOacEnabled}

          ensure_dependencies() {
            if [ "$oac_enabled" != "true" ]; then
              printf 'error: programs.opencode.oac.enable must be true; enable yuri-opencode/oac-flake first.\n' >&2
              exit 1
            fi

            if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
              printf 'error: not inside a git repository.\n' >&2
              exit 1
            fi

            if ! command -v opencode >/dev/null 2>&1; then
              printf 'error: opencode is not available in PATH.\n' >&2
              exit 1
            fi
          }

          has_staged_changes() {
            ! git diff --cached --quiet --exit-code
          }

          confirm_stage_all() {
            printf 'No staged changes found. Run git add -A? [y/N] '
            read -r answer
            case "$answer" in
              y|Y|yes|YES) git add -A ;;
              *) printf 'No changes staged; aborting.\n'; exit 0 ;;
            esac
          }

          write_commit_prompt() {
            prompt_file=$1
            {
              printf 'You are %s.\n' "$opencode_agent"
              printf 'Summarize the staged git changes against the previous commit, then generate an atomic commit message.\n'
              printf 'Use a concise subject and optional body. Focus on why the change exists.\n'
              printf 'Print a human-readable summary first, then place only the final commit message between BEGIN_COMMIT_MESSAGE and END_COMMIT_MESSAGE markers.\n\n'
              printf 'Git status --short:\n'
              git status --short
              printf '\nStaged diff stat:\n'
              git diff --cached --stat
              printf '\nStaged diff against HEAD / previous commit:\n'
              git diff --cached --find-renames --find-copies --no-ext-diff
            } > "$prompt_file"
          }

          run_opencode() {
            prompt_file=$1
            opencode --agent "$opencode_agent" run --model "$opencode_model" < "$prompt_file"
          }

          extract_commit_message() {
            sed -n '/^BEGIN_COMMIT_MESSAGE$/,/^END_COMMIT_MESSAGE$/p' | sed '1d;$d'
          }

          commit_with_message() {
            message=$1
            mode=$2
            message_file=$(mktemp)
            printf '%s\n' "$message" > "$message_file"

            case "$mode" in
              y|Y|yes|YES)
                git commit -F "$message_file"
                ;;
              m|M|modify|MODIFY)
                git commit --edit -F "$message_file"
                ;;
              n|N|no|NO)
                printf 'Commit skipped.\n'
                ;;
              *)
                printf 'Unrecognized answer; commit skipped.\n' >&2
                ;;
            esac

            rm -f "$message_file"
          }

          maybe_push() {
            printf 'Run git push? [y/N] '
            read -r answer
            case "$answer" in
              y|Y|yes|YES) git push ;;
              *) printf 'Push skipped.\n' ;;
            esac
          }

          ensure_dependencies

          git -c color.status=always status

          if ! has_staged_changes; then
            confirm_stage_all
          fi

          if ! has_staged_changes; then
            printf 'No staged changes remain after staging prompt; aborting.\n'
            exit 0
          fi

          prompt_file=$(mktemp)
          output_file=$(mktemp)
          trap 'rm -f "$prompt_file" "$output_file"' EXIT

          write_commit_prompt "$prompt_file"
          run_opencode "$prompt_file" | tee "$output_file"

          commit_message=$(extract_commit_message < "$output_file")
          if [ -z "$commit_message" ]; then
            printf 'error: OpenCode did not return a commit message between markers.\n' >&2
            exit 1
          fi

          printf 'Run git commit with the generated message? [y/M/n] '
          read -r commit_answer
          commit_with_message "$commit_message" "''${commit_answer:-M}"

          if git rev-parse --verify HEAD >/dev/null 2>&1; then
            maybe_push
          fi
        '';
      };

      gitAiPrDraft = pkgs.writeShellApplication {
        name = "git-ai-pr-draft";
        inherit runtimeInputs;
        text = ''
          set -euo pipefail

          opencode_model=${lib.escapeShellArg model}
          opencode_agent=${lib.escapeShellArg agent}
          oac_enabled=${lib.boolToString isOacEnabled}

          ensure_dependencies() {
            if [ "$oac_enabled" != "true" ]; then
              printf 'error: programs.opencode.oac.enable must be true; enable yuri-opencode/oac-flake first.\n' >&2
              exit 1
            fi

            if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
              printf 'error: not inside a git repository.\n' >&2
              exit 1
            fi

            if ! command -v opencode >/dev/null 2>&1; then
              printf 'error: opencode is not available in PATH.\n' >&2
              exit 1
            fi
          }

          detect_base_ref() {
            if [ "''${1:-}" != "" ]; then
              printf '%s\n' "$1"
            elif git rev-parse --verify --quiet origin/HEAD >/dev/null; then
              git symbolic-ref --quiet --short refs/remotes/origin/HEAD
            elif git rev-parse --verify --quiet origin/main >/dev/null; then
              printf 'origin/main\n'
            elif git rev-parse --verify --quiet origin/master >/dev/null; then
              printf 'origin/master\n'
            elif git rev-parse --verify --quiet main >/dev/null; then
              printf 'main\n'
            elif git rev-parse --verify --quiet master >/dev/null; then
              printf 'master\n'
            else
              printf 'error: could not detect a PR base ref; pass one as the first argument.\n' >&2
              exit 1
            fi
          }

          write_pr_prompt() {
            prompt_file=$1
            base_ref=$2
            merge_base=$(git merge-base "$base_ref" HEAD)
            current_branch=$(git branch --show-current)

            {
              printf 'You are %s.\n' "$opencode_agent"
              printf 'Generate a complete draft Pull Request for the local branch. Do not submit it to GitHub.\n'
              printf 'Return terminal-ready markdown with: title, summary, changes, validation/test plan, risks, and reviewer notes.\n'
              printf 'Base ref: %s\nCurrent branch: %s\nMerge base: %s\n\n' "$base_ref" "$current_branch" "$merge_base"
              printf 'Commit log:\n'
              git log --oneline --decorate "$merge_base..HEAD"
              printf '\nDiff stat:\n'
              git diff --stat "$merge_base...HEAD"
              printf '\nDiff:\n'
              git diff --find-renames --find-copies --no-ext-diff "$merge_base...HEAD"
            } > "$prompt_file"
          }

          run_opencode() {
            prompt_file=$1
            opencode --agent "$opencode_agent" run --model "$opencode_model" < "$prompt_file"
          }

          ensure_dependencies

          base_ref=$(detect_base_ref "''${1:-}")
          prompt_file=$(mktemp)
          trap 'rm -f "$prompt_file"' EXIT

          write_pr_prompt "$prompt_file" "$base_ref"
          run_opencode "$prompt_file"
        '';
      };
    in
    {
      assertions = [
        {
          assertion = isOpenCodeEnabled && isOacEnabled;
          message = "git-commit-helpers refuses to build unless oac-flake is enabled via programs.opencode.oac.enable.";
        }
      ];

      home.packages = [
        gitAiCommit
        gitAiPrDraft
      ];
    };
}
