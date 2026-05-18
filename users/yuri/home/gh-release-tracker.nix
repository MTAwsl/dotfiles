_: {
  flake.modules.users.yuri.home.gh-release-tracker =
    { pkgs, ... }:
    let
      script = pkgs.writeShellApplication {
        name = "github-release-chk-update";
        runtimeInputs = with pkgs; [
          bash
          coreutils
          jq
          libnotify
        ];
        text = ''
          if ! command -v ${pkgs.jq}/bin/jq &> /dev/null; then
              ${pkgs.libnotify}/notify-send -a "Github Release Auto Sync" "Dependency Error" "'jq' is required but not installed. Please check your NixOS configuration."
              exit 1
          fi

          usage() {
              echo "Usage: $0 -r <owner/repo> [-f]"
              echo "  -r    GitHub repository (e.g., 'google/googletest')"
              echo "  -d    Directory to store artifacts."
              echo "  -f    Force download even if version matches"
              exit 1
          }

          FORCE=0
          while getopts "r:d:f" opt; do
              case "$opt" in
                  r) REPO=$OPTARG ;;
                  d) SCRIPT_DIR=$OPTARG ;;
                  f) FORCE=1 ;;
                  *) usage ;;
              esac
          done

          if [ -z "$REPO" ] || [ -z "$SCRIPT_DIR" ]; then
              usage
          fi

          REPONAME="''${REPO#*/}"
          VERSION_FILE="$SCRIPT_DIR/.version"

          mkdir -p "$SCRIPT_DIR/$REPONAME"

          echo "Checking GitHub for updates on $REPO..."
          RELEASE_DATA=$(${pkgs.curl}/bin/curl -s "https://api.github.com/repos/$REPO/releases/latest")

          LATEST_TAG=$(echo "$RELEASE_DATA" | jq -r '.tag_name')
          if [ -f "$VERSION_FILE" ]; then
              if [ "$FORCE" -eq 1 ]; then
                echo "{}" > "$VERSION_FILE"
              fi
              CURRENT_TAG=$(jq -r ".\"''${REPO}\"" < "$VERSION_FILE")
          else
              CURRENT_TAG="~" # Illigal charactor in Git Tag
              echo "{}" > "$VERSION_FILE"
          fi

          if [ "$LATEST_TAG" == "$CURRENT_TAG" ]; then
              echo "Already up to date (Version: $CURRENT_TAG)."
              exit 0
          fi

          ${pkgs.libnotify}/bin/notify-send -a "Github Release Auto Sync" "New version found" "[$REPONAME] New version: $LATEST_TAG (Current: $CURRENT_TAG)"
          echo "Downloading artifacts..."
          echo "$RELEASE_DATA" | jq -r '.assets[].browser_download_url' | while read -r url; do
              echo "Fetching: ''${url##*/}"

              if ! curl -f -L -s -o "$SCRIPT_DIR/$REPONAME/''${url##*/}" "$url"; then
                ${pkgs.libnotify}/bin/notify-send -a "Github Release Auto Sync" "Network Error" "curl exited with a non-zero status."
                exit 1
              fi
          done

          TMPFILE=$(mktemp)
          trap 'rm -rf "$TMPFILE"' EXIT

          jq ".\"''${REPO}\" = \"$LATEST_TAG\"" < "$VERSION_FILE" > "$TMPFILE"
          mv "$TMPFILE" "$VERSION_FILE"
          ${pkgs.libnotify}/bin/notify-send -a "Github Release Auto Sync" "Update Complete" "Successfully updated $REPONAME to $LATEST_TAG."
        '';
      };

      artifact_dir = "/home/yuri/gh-release-artifacts";
    in
    {
      systemd.user.services.gh-release-chk-update-weekly = {
        Unit = {
          Description = "Weekly Auto Upgrade Check on Github Release Artifacts";

          After = [ "network-online.target" ];
          Wants = [ "network-online.target" ];

          StartLimitIntervalSec = 3600;
          StartLimitBurst = 5;
        };

        Service = {
          Type = "oneshot";
          ExecStart = ''
            ${pkgs.bash}/bin/bash -c '${script}/bin/github-release-chk-update -r YuriNek0/GhostPack-Precompiled -d "${artifact_dir}"; ${script}/bin/github-release-chk-update -r YuriNek0/SharpWeb -d "${artifact_dir}"'
          '';

          Restart = "on-failure";
          RestartSec = "60s";
        };
      };

      systemd.user.timers.gh-release-chk-update-weekly = {
        Unit = {
          Description = "Timer for Weekly Github Release Check";
        };
        Timer = {
          OnCalendar = "weekly";
          Persistent = true;
          Unit = "gh-release-chk-update-weekly.service";
        };
        Install = {
          WantedBy = [ "timers.target" ];
        };
      };
    };
}
