_: {
  flake.modules.users.yuri.home.nnn =
    { pkgs, ... }:
    let
      nnnPackage = pkgs.nnn.override { withNerdIcons = true; };
      previewImageCommand = "chafa -f symbols --symbols block+border+space --fill braille";
      previewPath = pkgs.lib.makeBinPath (
        with pkgs;
        [
          atool
          bat
          chafa
          djvulibre
          eza
          ffmpeg
          ffmpegthumbnailer
          file
          glow
          imagemagick
          jq
          mediainfo
          mpv
          poppler-utils
          tree
          unzip
          zellij
        ]
      );

      closePreview = ''
        if [ -n "''${NNN_FIFO:-}" ] && [ -p "$NNN_FIFO" ]; then
          ${pkgs.coreutils}/bin/timeout 0.2s ${pkgs.bash}/bin/bash -c 'printf "close\n" > "$1"' sh "$NNN_FIFO" >/dev/null 2>&1 || true
        fi
      '';

      reopenPreview = ''
        if [ -n "''${NNN_FIFO:-}" ] && [ -p "$NNN_FIFO" ]; then
          ${pkgs.coreutils}/bin/sleep 0.1
          ${pkgs.bash}/bin/bash ${pkgs.nnn.src}/plugins/preview-tui "''${target:-}" >/dev/null 2>&1 || true
        fi
      '';

      seedPreview = ''
        if [ -n "''${NNN_FIFO:-}" ] && [ -p "$NNN_FIFO" ] && [ -n "''${target:-}" ]; then
          ${pkgs.coreutils}/bin/sleep 0.1
          ${pkgs.coreutils}/bin/timeout 0.2s ${pkgs.bash}/bin/bash -c 'printf "%s\n" "$1" > "$2"' sh "$target" "$NNN_FIFO" >/dev/null 2>&1 || true
        fi
      '';

      nnnOpener = pkgs.writeShellScriptBin "nnn-open" ''
        if [ "$#" -eq 0 ]; then
          exit 0
        fi

        for target in "$@"; do
          mime="$(${pkgs.file}/bin/file --brief --mime-type -- "$target" 2>/dev/null || true)"

          case "$mime" in
            text/*|application/json|application/xml|application/x-shellscript|inode/x-empty)
              ${closePreview}
              ${pkgs.helix}/bin/hx "$target"
              ${reopenPreview}
              ${seedPreview}
              ;;
            *)
              if command -v xdg-open >/dev/null 2>&1; then
                nohup xdg-open "$target" >/dev/null 2>&1 &
                ${seedPreview}
              else
                ${closePreview}
                ${pkgs.helix}/bin/hx "$target"
                ${reopenPreview}
                ${seedPreview}
              fi
              ;;
          esac
        done
      '';

      hxNnnPreviewCommand = pkgs.writeShellScript "hx-nnn-preview" ''
        set -u

        fifo="''${1:?fifo required}"

        clear_preview() {
          printf '\033[2J\033[H'
        }

        preview_path() {
          target="$1"
          clear_preview

          if [ -z "$target" ] || [ "$target" = "close" ]; then
            return 0
          fi

          if [ -d "$target" ]; then
            ${pkgs.eza}/bin/eza --tree --level=2 --icons=auto --color=always -- "$target" 2>/dev/null \
              || ${pkgs.coreutils}/bin/ls -la -- "$target"
            return 0
          fi

          if [ ! -e "$target" ]; then
            printf 'Missing: %s\n' "$target"
            return 0
          fi

          mime="$(${pkgs.file}/bin/file --brief --mime-type -- "$target" 2>/dev/null || true)"

          case "$mime" in
            image/*)
              ${pkgs.chafa}/bin/chafa --clear -- "$target" 2>/dev/null \
                || ${pkgs.file}/bin/file --brief -- "$target"
              ;;
            text/*|application/json|application/xml|application/x-shellscript|inode/x-empty)
              ${pkgs.bat}/bin/bat --paging=never --plain --color=always --line-range :200 -- "$target" 2>/dev/null \
                || ${pkgs.coreutils}/bin/head -n 200 -- "$target"
              ;;
            *)
              ${pkgs.file}/bin/file --brief -- "$target"
              ;;
          esac
        }

        while IFS= read -r selection; do
          if [ "$selection" = "close" ]; then
            break
          fi

          preview_path "$selection"
        done < "$fifo"

        clear_preview
      '';

      hxNnnPickerOpener = pkgs.writeShellScript "hx-nnn-picker-open" ''
        set -u

        target="''${1:-}"
        if [ -z "$target" ]; then
          exit 0
        fi

        if [ -e "$target" ]; then
          target="$(${pkgs.coreutils}/bin/realpath -- "$target")"
        fi

        ${closePreview}

        if [ -n "''${HX_NNN_SELECTION_FILE:-}" ]; then
          printf '%s\n' "$target" > "$HX_NNN_SELECTION_FILE"
        fi

        if [ -n "''${NNN_PARENT:-}" ]; then
          kill -TERM "$NNN_PARENT" 2>/dev/null || true
        else
          kill -TERM "$PPID" 2>/dev/null || true
        fi
      '';

      nnnPickerCommand = pkgs.writeShellScript "hx-nnn-picker-command" ''
        set -u

        selection_file="''${1:?selection file required}"
        start_path="''${2:-.}"
        fifo="''${3:?fifo required}"

        export PATH="${previewPath}:$PATH"
        export HX_NNN_SELECTION_FILE="$selection_file"
        export NNN_OPENER="${hxNnnPickerOpener}"
        export NNN_PREVIEWIMGPROG="${previewImageCommand}"
        export NNN_FIFO="$fifo"
        export NNN_SPLIT="v"
        export NNN_SPLITSIZE="45"
        if [ -n "''${ZELLIJ:-}" ]; then
          export NNN_TERMINAL="zellij"
        else
          unset NNN_TERMINAL
        fi
        export NNN_PLUG='p:preview-tui;f:fzopen;g:gitroot;x:!chmod +x "$nnn"'
        export EDITOR="hx"
        export VISUAL="hx"

        exec ${nnnPackage}/bin/nnn -c "$start_path"
      '';

      hxNnnPicker = pkgs.writeShellScriptBin "hx-nnn-picker" ''
        set -u

        start_path="''${1:-.}"
        if [ -z "$start_path" ]; then
          start_path="."
        fi

        if [ -f "$start_path" ]; then
          start_path="$(${pkgs.coreutils}/bin/dirname -- "$start_path")"
        fi

        if [ ! -d "$start_path" ]; then
          start_path="$PWD"
        fi

        picker_tmpdir="$(${pkgs.coreutils}/bin/mktemp -d --tmpdir hx-nnn-picker.XXXXXX)"
        selection_file="$picker_tmpdir/selection"
        fifo="$picker_tmpdir/fifo"
        ${pkgs.coreutils}/bin/mkfifo -- "$fifo"

        cleanup() {
          if [ -p "$fifo" ]; then
            ${pkgs.coreutils}/bin/timeout 0.2s ${pkgs.bash}/bin/bash -c 'printf "close\n" > "$1"' sh "$fifo" >/dev/null 2>&1 || true
          fi
          ${pkgs.coreutils}/bin/rm -rf -- "$picker_tmpdir"
        }
        trap cleanup EXIT

        if [ -n "''${ZELLIJ:-}" ]; then
          ${pkgs.zellij}/bin/zellij run \
            --floating \
            --width 45% \
            --height 90% \
            --x 50% \
            --y 5% \
            --name "nnn-preview" \
            --close-on-exit \
            --cwd "$start_path" \
            -- ${hxNnnPreviewCommand} "$fifo" >/dev/null 2>&1

          ${pkgs.zellij}/bin/zellij run \
            --floating \
            --width 45% \
            --height 90% \
            --x 5% \
            --y 5% \
            --name "nnn-picker" \
            --close-on-exit \
            --blocking \
            --cwd "$start_path" \
            -- ${nnnPickerCommand} "$selection_file" "$start_path" "$fifo" >/dev/null 2>&1
        else
          ${hxNnnPreviewCommand} "$fifo" >/dev/null 2>&1 &
          saved_tty="$(${pkgs.coreutils}/bin/stty -g < /dev/tty 2>/dev/null || true)"
          ${pkgs.coreutils}/bin/stty sane < /dev/tty 2>/dev/null || true
          ${nnnPickerCommand} "$selection_file" "$start_path" "$fifo" < /dev/tty
          if [ -n "$saved_tty" ]; then
            ${pkgs.coreutils}/bin/stty "$saved_tty" < /dev/tty 2>/dev/null || true
          fi
        fi

        if [ -s "$selection_file" ]; then
          ${pkgs.coreutils}/bin/head -n 1 -- "$selection_file"
        fi
      '';

      nnnCdOnQuit = ''
        function nnn() {
          if [ "''${NNNLVL:-0}" -ge 1 ]; then
            echo "nnn is already running"
            return 1
          fi

          local nnn_tmpfile="''${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.lastd"
          export NNN_TMPFILE="$nnn_tmpfile"
          export PATH="${previewPath}:$PATH"
          export NNN_OPENER="${nnnOpener}/bin/nnn-open"
          export NNN_PREVIEWIMGPROG="${previewImageCommand}"
          export NNN_SPLIT="v"
          export NNN_SPLITSIZE="45"
          if [ -n "''${ZELLIJ:-}" ]; then
            export NNN_TERMINAL="zellij"
          else
            unset NNN_TERMINAL
          fi
          export EDITOR="hx"
          export VISUAL="hx"

          command nnn "$@"

          if [ -f "$NNN_TMPFILE" ]; then
            . "$NNN_TMPFILE"
            rm -f -- "$NNN_TMPFILE" >/dev/null
          fi
        }
      '';
    in
    {
      programs.nnn = {
        enable = true;
        package = nnnPackage;
        enableBashIntegration = true;
        enableZshIntegration = true;
        quitcd = false;

        options = [
          "-a"
          "-c"
          "-P"
          "p"
        ];

        extraPackages = with pkgs; [
          atool
          bat
          chafa
          djvulibre
          eza
          ffmpeg
          ffmpegthumbnailer
          file
          glow
          imagemagick
          jq
          mediainfo
          mpv
          poppler-utils
          tree
          unzip
          hxNnnPicker
          nnnOpener
        ];

        plugins = {
          src = pkgs.nnn.src + "/plugins";
          mappings = {
            p = "preview-tui";
            f = "fzopen";
            g = "gitroot";
            h = "-!hx \"$nnn\"*";
            x = "!chmod +x \"$nnn\"";
          };
        };
      };

      home.packages = [
        hxNnnPicker
        nnnOpener
      ];

      programs.bash.initExtra = nnnCdOnQuit;
      programs.zsh = {
        initContent = nnnCdOnQuit;
      };

      home.sessionVariables = {
        NNN_OPENER = "${nnnOpener}/bin/nnn-open";
        NNN_PREVIEWIMGPROG = previewImageCommand;
        NNN_SPLIT = "v";
        NNN_SPLITSIZE = "45";
        EDITOR = "hx";
        VISUAL = "hx";
      };
    };
}
