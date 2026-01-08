{ ... }:
{
  flake.modules.homeManager.yuri-niri =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      programs = {
        niri.settings = {
          # nvidia fix, remove once either
          # https://github.com/YaLTeR/niri/issues/2030
          # https://github.com/YaLTeR/niri/issues/2477
          # is closed
          debug.wait-for-frame-completion-before-queueing = [ ];

          # Update after refactor: https://github.com/sodiboo/niri-flake/pull/1548

          # Waiting for https://github.com/sodiboo/niri-flake/issues/1446 is closed
          # before integrating below config:
          # '''kdl
          # recent-windows {
          #     highlight {
          #         corner-radius 12
          #         active-color   "#124a73"
          #         urgent-color   "#ffb4ab"
          #     }
          # }
          # '''

          hotkey-overlay.skip-at-startup = true;
          prefer-no-csd = true;

          input.keyboard.numlock = true;

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
            QT_QPA_PLATFORM = "wayland";
            ELECTRON_OZONE_PLATFORM_HINT = "auto";
            QT_QPA_PLATFORMTHEME = "gtk3";
            QT_QPA_PLATFORMTHEME_QT6 = "gtk3";
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

          window-rules = [
            {
              geometry-corner-radius = {
                bottom-left = 6.;
                bottom-right = 6.;
                top-left = 6.;
                top-right = 6.;
              };
              clip-to-geometry = true;
              tiled-state = true;
              draw-border-with-background = false;
            }
            {
              matches = [
                { app-id = "^firefox-devedition$"; }
              ];
              open-on-workspace = "1";
            }
            {
              matches = [
                { app-id = "org.quickshell$"; }
              ];
              open-floating = true;
            }
            {
              matches = [
                {
                  app-id = "^com.mitchellh.ghostty$";
                  at-startup = true;
                }
              ];
              open-on-workspace = "2";
              default-column-width.proportion = 1.;
            }
            {
              matches = [
                { app-id = "^org.telegram.desktop$"; }
                { app-id = "^vesktop$"; }
              ];
              open-on-workspace = "3";
            }
            {
              matches = [
                { app-id = "com.mitchellh.ghostty"; }
              ];
              draw-border-with-background = true;
            }
            {
              matches = [
                { is-active = false; }
              ];
              opacity = 0.9;
            }
          ];

          spawn-at-startup = [
            { sh = "wl-paste --type text --watch cliphist store &"; }
            { sh = "wl-paste --type image --watch cliphist store &"; }
            { sh = "kdeconnect-indicator &"; }
            # { sh = "app2unit -- firefox-devedition"; }
            # { sh = ''app2unit -- ghostty -e zsh -l -c "zellij a -c defaulted"''; }
            # { sh = "app2unit -- vesktop"; }
          ];

          binds =
            with config.lib.niri.actions;
            let
              # https://github.com/sodiboo/system/blob/a6ff1448f3d9cafe55e79a68802f03d76d4894b4/personal/niri.mod.nix#L31
              binds =
                {
                  suffixes,
                  prefixes,
                  substitutions ? { },
                }:
                let
                  replacer = lib.replaceStrings (lib.attrNames substitutions) (lib.attrValues substitutions);
                  format =
                    prefix: suffix:
                    let
                      actual-suffix =
                        if lib.isList suffix.action then
                          {
                            action = lib.head suffix.action;
                            args = lib.tail suffix.action;
                          }
                        else
                          {
                            inherit (suffix) action;
                            args = [ ];
                          };

                      action = replacer "${prefix.action}-${actual-suffix.action}";
                    in
                    {
                      name = "${prefix.key}+${suffix.key}";
                      value.action.${action} = actual-suffix.args;
                    };
                  pairs =
                    attrs: fn:
                    lib.concatMap (
                      key:
                      fn {
                        inherit key;
                        action = attrs.${key};
                      }
                    ) (lib.attrNames attrs);
                in
                lib.listToAttrs (pairs prefixes (prefix: pairs suffixes (suffix: [ (format prefix suffix) ])));
            in
            lib.attrsets.mergeAttrsList [
              {
                "Mod+Shift+Slash".action = show-hotkey-overlay;

                "Mod+T".action = spawn-sh "app2unit -- ghostty";
                "Mod+Space" = {
                  hotkey-overlay.title = "Application Launcher";
                  action = spawn-sh "dms ipc call spotlight toggle";
                };

                "Mod+Alt+L" = {
                  hotkey-overlay.title = "Lock Screen";
                  action = spawn "dms" "ipc" "call" "lock" "lock";
                };

                "Mod+Alt+S" = {
                  action = spawn-sh "pkill orca || exec orca";
                  allow-when-locked = true;
                };

                "XF86AudioRaiseVolume" = {
                  action = spawn-sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.01+";
                  allow-when-locked = true;
                };
                "XF86AudioLowerVolume" = {
                  action = spawn-sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.01-";
                  allow-when-locked = true;
                };
                "XF86AudioMute" = {
                  action = spawn-sh "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
                  allow-when-locked = true;
                };
                "XF86AudioMicMute" = {
                  action = spawn-sh "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
                  allow-when-locked = true;
                };

                "XF86MonBrightnessUp" = {
                  action = spawn "dms" "ipc" "call" "brightness" "increment" "5" "";
                  allow-when-locked = true;
                };
                "XF86MonBrightnessDown" = {
                  action = spawn "dms" "ipc" "call" "brightness" "decrement" "5" "";
                  allow-when-locked = true;
                };

                "Mod+O" = {
                  action = toggle-overview;
                  repeat = false;
                };

                "Mod+Q" = {
                  action = close-window;
                  repeat = false;
                };

                "Mod+Tab".action = focus-workspace-previous;

                "Mod+BracketLeft".action = consume-or-expel-window-left;
                "Mod+BracketRight".action = consume-or-expel-window-right;

                # "Mod+Comma".action = consume-window-into-column;
                "Mod+Comma" = {
                  hotkey-overlay.title = "Settings";
                  action = spawn "dms" "ipc" "call" "settings" "focusOrToggle";
                };

                "Mod+Period".action = expel-window-from-column;

                "Mod+R".action = switch-preset-column-width;
                "Mod+Shift+R".action = switch-preset-window-height;
                "Mod+Ctrl+R".action = reset-window-height;

                "Mod+F".action = maximize-column;
                "Mod+Shift+F".action = fullscreen-window;
                "Mod+Ctrl+F".action = expand-column-to-available-width;

                "Mod+C".action = center-column;
                "Mod+Ctrl+C".action = center-visible-columns;

                "Mod+Minus".action = set-column-width "-10%";
                "Mod+Equal".action = set-column-width "+10%";
                "Mod+Shift+Minus".action = set-window-height "-10%";
                "Mod+Shift+Equal".action = set-window-height "+10%";

                "Mod+Shift+T".action = toggle-window-floating;
                "Mod+Shift+V".action = switch-focus-between-floating-and-tiling;

                "Mod+V" = {
                  hotkey-overlay.title = "Clipboard Manager";
                  action = spawn "dms" "ipc" "call" "clipboard" "toggle";
                };

                "Mod+M" = {
                  hotkey-overlay.title = "Task Manager";
                  action = spawn "dms" "ipc" "call" "processlist" "focusOrToggle";
                };

                "Mod+N" = {
                  hotkey-overlay.title = "Notification Center";
                  action = spawn "dms" "ipc" "call" "notifications" "toggle";
                };

                "Mod+Y" = {
                  hotkey-overlay.title = "Browse Wallpapers";
                  action = spawn "dms" "ipc" "call" "dankdash" "wallpaper";
                };

                "Mod+W".action = toggle-column-tabbed-display;

                "Print".action.screenshot = [ ];
                "Ctrl+Print".action.screenshot-screen = [ ];
                "Alt+Print".action.screenshot-window = [ ];

                "XF86Launch1".action.screenshot = [ ];
                "Ctrl+XF86Launch1".action.screenshot-screen = [ ];
                "Alt+XF86Launch1".action.screenshot-window = [ ];

                "Mod+Escape" = {
                  action = toggle-keyboard-shortcuts-inhibit;
                  allow-inhibiting = false;
                };

                "Mod+Shift+E".action = quit;
                "Ctrl+Alt+Delete".action = quit;

                "Mod+Shift+P".action = power-off-monitors;

                "Mod+WheelScrollDown" = {
                  action.focus-workspace-down = [ ];
                  cooldown-ms = 150;
                };
                "Mod+WheelScrollUp" = {
                  action.focus-workspace-up = [ ];
                  cooldown-ms = 150;
                };
                "Mod+Ctrl+WheelScrollDown" = {
                  action.move-column-to-workspace-down = [ ];
                  cooldown-ms = 150;
                };
                "Mod+Ctrl+WheelScrollUp" = {
                  action.move-column-to-workspace-up = [ ];
                  cooldown-ms = 150;
                };
              }
              (binds {
                suffixes."Left" = "column-left";
                suffixes."Down" = "window-down";
                suffixes."Up" = "window-up";
                suffixes."Right" = "column-right";
                suffixes."H" = "column-left";
                suffixes."J" = "window-down";
                suffixes."K" = "window-up";
                suffixes."L" = "column-right";
                prefixes."Mod" = "focus";
                prefixes."Mod+Ctrl" = "focus-monitor";
                prefixes."Mod+Shift" = "move";
                prefixes."Mod+Shift+Ctrl" = "move-column-to-monitor";
                substitutions."monitor-column" = "monitor";
                substitutions."monitor-window" = "monitor";
              })
              (binds {
                suffixes."Home" = "first";
                suffixes."End" = "last";
                prefixes."Mod" = "focus-column";
                prefixes."Mod+Ctrl" = "move-column-to";
              })
              (binds {
                suffixes."WheelScrollRight" = "right";
                suffixes."WheelScrollLeft" = "left";
                prefixes."Mod" = "focus-column";
                prefixes."Mod+Ctrl" = "move-column";
              })
              (binds {
                suffixes."WheelScrollDown" = "right";
                suffixes."WheelScrollUp" = "left";
                prefixes."Mod+Shift" = "focus-column";
                prefixes."Mod+Ctrl+Shift" = "move-column";
              })
              (binds {
                suffixes."Page_Down" = "workspace-down";
                suffixes."Page_Up" = "workspace-up";
                suffixes."U" = "workspace-down";
                suffixes."I" = "workspace-up";
                prefixes."Mod" = "focus";
                prefixes."Mod+Ctrl" = "move-column-to";
                prefixes."Mod+Shift" = "move";
              })
              (binds {
                suffixes =
                  (lib.range 1 9)
                  |> map (n: {
                    name = toString n;
                    value = [
                      "workspace"
                      n
                    ];
                  })
                  |> builtins.listToAttrs;
                prefixes."Mod" = "focus";
                prefixes."Mod+Shift" = "move-column-to";
              })
            ];
        };

        ghostty = {
          enable = true;
          settings = {
            font-family = "Monaspace Neon NF"; # handled by stylix
            font-style = "Light";
            font-feature = "calt, ss01, ss02, ss03, ss04, ss05, ss06, ss07, ss08, ss09, ss10, liga";
            shell-integration = "zsh";
            shell-integration-features = "sudo, title, ssh-env";
          };
        };
      };

      services.kdeconnect.enable = true;

      xdg.configFile."uwsm/env-niri".text = ''
        export APP2UNIT_SLICES="a=app-graphical.slice b=background-graphical.slice s=session-graphical.slice"
        export APP2UNIT_TYPE="scope"
      '';
    };
}
