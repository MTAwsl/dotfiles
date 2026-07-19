_: {
  flake.modules.users.yuri.home.helix-editor = { pkgs, ... }: {
    programs.helix.settings = {
      # theme = "monokai"; # Managed by stylix
      editor = {
        cursorline = true;
        true-color = true;
        color-modes = true;
        bufferline = "multiple";
        line-number = "relative";
        rulers = [
          89
          120
        ];
        indent-guides.render = true;
        soft-wrap = {
          enable = true;
          max-wrap = 25;
          max-indent-retain = 0;
          wrap-indicator = "";
        };

        end-of-line-diagnostics = "warning";
        inline-diagnostics.cursor-line = "warning";
      };

      keys.normal = {
        esc = [
          "collapse_selection"
          "keep_primary_selection"
        ];

        # Zellij owns these Alt bindings for pane/tab navigation and resizing.
        "A-a" = "no_op";
        "A-b" = "no_op";
        "A-e" = "no_op";
        "A-i" = "no_op";
        "A-down" = "no_op";
        "A-n" = "no_op";
        "A-right" = "no_op";
        "A-o" = "no_op";
        "A-up" = "no_op";
        "A-p" = "no_op";
        "A-left" = "no_op";
        "A-minus" = "no_op";

        m = {
          h = "select_prev_sibling";
          j = "shrink_selection";
          k = "expand_selection";
          l = "select_next_sibling";
          b = "move_parent_node_start";
          e = "move_parent_node_end";
          c = "select_all_children";
          x = "select_all_siblings";
        };
      };

      keys.normal.space = {
        # replace file explorer with nnn
        # e = ":open %sh{hx-nnn-picker '%{buffer_name}'}";
        # replace file explorer with yazi
        e =
          let
            yazi-wrapper = pkgs.writeShellScript "yazi-wrapper" ''
              if [[ -n $ZELLIJ ]]; then
                YAZI_TMP=$(mktemp -d)

                mkfifo "$YAZI_TMP/fifo"

                zellij run -fc --width 90% --height 90% -x 5% -y 5% -- \
                  sh -c "${pkgs.yazi}/bin/yazi \"$1\" --chooser-file=\"$YAZI_TMP/out\" | tee \"$YAZI_TMP/fifo\"" > /dev/null

                cat < "$YAZI_TMP/fifo" > /dev/null

                cat "$YAZI_TMP/out"
                rm -rf "$YAZI_TMP"
              else
                # use the system stty if possible to fix permission issue
                # on macos
                STTY=stty
                if [ -f /bin/stty ]; then
                  STTY=/bin/stty
                fi

                # save and restore tty settings
                # the "official" version fixes settings by using stuff like
                # `x1b[?1049h]`, which is not what helix uses exactly.
                # this script just save and restores it instead.
                SAVED_TTY=$($STTY -g < /dev/tty)
                $STTY sane < /dev/tty

                ${pkgs.yazi}/bin/yazi "$1" --chooser-file=/dev/stdout < /dev/tty

                $STTY "$SAVED_TTY" < /dev/tty
              fi
            '';
          in
          [
            ":set mouse false"
            ":open %sh{${yazi-wrapper} '%{buffer_name}'}"
            ":redraw"
            ":set mouse true"
          ];
      };
    };
  };
}
