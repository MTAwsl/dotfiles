{ self, ... }:
{
  flake.modules.users.yuri.home.niri =
    {
      pkgs,
      ...
    }:
    {
      imports = with self.modules.users.yuri.home; [
        niri-binds
        niri-window-rules
      ];

      home.packages = with pkgs; [
        # Screenshot
        flameshot
        libnotify

        # KDE Connect is an overkill for clipboard sharing.
        # kde-connect
      ];

      programs = {

        # Update after refactor: https://github.com/sodiboo/niri-flake/pull/1548
        # Waiting for https://github.com/sodiboo/niri-flake/issues/1446 is closed
        # niri.config = with inputs.niri.lib.kdl; [
        #   (node "recent-windows" "highlight" [
        #     (leaf "corner-radius" 12)
        #     (leaf "active-color" "#124a73")
        #     (leaf "urgent-color" "#ffb4ab")
        #   ])
        # ];

        niri.settings = {
          # nvidia fix, remove once either
          # https://github.com/YaLTeR/niri/issues/2030
          # https://github.com/YaLTeR/niri/issues/2477
          # is closed
          # debug.wait-for-frame-completion-before-queueing = [ ];

          hotkey-overlay.skip-at-startup = true;
          prefer-no-csd = true;

          input.keyboard.numlock = true;

          clipboard.disable-primary = true;

          layout = {
            gaps = 5;
            border = {
              enable = true;
              width = 1;
              active.color = "#ffc87f00"; # Set A channel to 0 to display only urgent color
              inactive.color = "#505050";
              urgent.color = "#f07272";
            };

            focus-ring = {
              enable = true;
              width = 1;
              active.color = "#bd93f9";
              inactive.color = "#6272a4";
              urgent.color = "#ffd700";
            };

            tab-indicator = {
              enable = true;
              active.color = "#bd93f9";
              inactive.color = "#6272a4";
              urgent.color = "#ffd700";
            };

            insert-hint = {
              display.color = "#bd93f980";
            };

            shadow.color = "#00000070";
            background-color = "transparent";
          };

          environment = {
            XDG_CURRENT_DESKTOP = "niri";
            XDG_SESSION_TYPE = "wayland";
            QT_QPA_PLATFORM = "wayland";
            ELECTRON_OZONE_PLATFORM_HINT = "auto";
            QT_QPA_PLATFORMTHEME = "gtk3";
            QT_QPA_PLATFORMTHEME_QT6 = "gtk3";
            APP2UNIT_SLICES = "a=app-graphical.slice b=background-graphical.slice s=session-graphical.slice";
            APP2UNIT_TYPE = "scope";
          };

          layer-rules = [
            {
              # Pin wallpaper to backgroud
              matches = [ { namespace = "^quickshell*"; } ];
              place-within-backdrop = true;
            }
            {
              # Pin wallpaper to backgroud
              matches = [ { namespace = "dms:blurwallpaper"; } ];
              place-within-backdrop = true;
            }
          ];

          overview.workspace-shadow.enable = false;

          animations.slowdown = 0.7;

          workspaces = {
            "1" = { };
            "2" = { };
            "3" = { };
            "4" = { };
            "5" = { };
            "6" = { };
            "7" = { };
            "8" = { };
            "9" = { };
          };

          spawn-at-startup = [
            { sh = "dbus-update-activation-environment --systemd --all"; }
            { sh = "app2unit -- firefox-devedition"; }
            { sh = ''app2unit -- ghostty -e zsh -l -c "zellij a -c defaulted"''; }
            { sh = "app2unit -- bitwarden"; }
            { sh = "app2unit -- vesktop"; }
            { sh = "app2unit -- Telegram"; }
            { sh = "niri msg action focus-workspace 4"; }
          ];

        };

        ghostty = {
          enable = true;
          settings = {
            window-width = 130;
            font-family = "Monaspace Neon NF"; # handled by stylix
            font-style = "Light";
            font-feature = "calt, ss01, ss02, ss03, ss04, ss05, ss06, ss07, ss08, ss09, ss10, liga";
            shell-integration = "zsh";
            shell-integration-features = "sudo, title, ssh-env";
            background-blur = true;
            window-save-state = "never";
            keybind = [
              "ctrl+tab=unbind"
              "ctrl+shift+tab=unbind"
            ];
          };
        };
      };

      xdg.configFile."uwsm/env".text = ''
        export XDG_CURRENT_DESKTOP="niri"
        export XDG_SESSION_TYPE="wayland"
        export APP2UNIT_SLICES="a=app-graphical.slice b=background-graphical.slice s=session-graphical.slice"
        export APP2UNIT_TYPE="scope"
      '';

    };
}
