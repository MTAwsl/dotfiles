{ ... }:
{
  flake.modules.homeManager.yuri-niri-binds =
    { config, lib, ... }:
    {
      programs.niri.settings.binds =
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

            "Mod+T" = {
              hotkey-overlay.title = "Launch Ghostty";
              action = spawn-sh "app2unit -- ghostty";
            };

            "Mod+Space" = {
              hotkey-overlay.title = "Application Launcher";
              action = spawn-sh "dms ipc call spotlight toggle";
            };

            "Mod+Alt+L" = {
              hotkey-overlay.title = "Lock Screen";
              action = spawn-sh "dms ipc call lock lock";
            };

            "Mod+Shift+S" = {
              hotkey-overlay.title = "Screenshot";
              # action = spawn-sh "output=$(niri msg --json focused-output | jq -r .name); grim -o $output - | satty --fullscreen --filename -";
              action = spawn-sh "flameshot gui";
            };

            # Uncomment to use orca
            # "Mod+Alt+S" = {
            #   hotkey-overlay.title = "Relaunch orca";
            #   action = spawn-sh "pkill orca || exec orca";
            #   allow-when-locked = true;
            # };

            "XF86AudioRaiseVolume" = {
              action = spawn-sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.02+ -l 1";
              allow-when-locked = true;
            };
            "XF86AudioLowerVolume" = {
              action = spawn-sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.02-";
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

            "Mod+Ctrl+Slash" = {
              hotkey-overlay.title = "Settings";
              action = spawn "dms" "ipc" "call" "settings" "focusOrToggle";
            };

            "Mod+Comma".action = consume-window-into-column;
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

            "Print" = {
              hotkey-overlay.title = "Screenshot (Native)";
              action.screenshot = [ ];
            };

            "Ctrl+Print" = {
              hotkey-overlay.title = "Screenshot Screen (Native)";
              action.screenshot-screen = [ ];
            };

            "Alt+Print" = {
              hotkey-overlay.title = "Screenshot Window (Native)";
              action.screenshot-window = [ ];
            };

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
            suffixes."I" = "workspace-down";
            suffixes."U" = "workspace-up";
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
}
