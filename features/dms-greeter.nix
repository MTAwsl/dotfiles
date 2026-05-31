{ self, ... }:
{
  flake.modules.features.dms-greeter = _: {
    services.displayManager.dms-greeter = {
      enable = true;
      compositor = {
        name = "niri";
        customConfig = ''
          input {
            keyboard {
              xkb {
                layout "us"
              }
            }
          }

          hotkey-overlay {
            skip-at-startup
          }

          environment {
            DMS_RUN_GREETER "1"
          }

          gestures {
            hot-corners {
              off
            }
          }
        '';
      };
      configHome = "/home/${self.lib.meta.owner.username}";
    };
  };
}
