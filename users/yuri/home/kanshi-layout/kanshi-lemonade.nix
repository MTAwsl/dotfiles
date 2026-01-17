{ ... }:
{
  flake.modules.homeManager.yuri-kanshi-lemonade =
    { ... }:
    {
      services.kanshi.settings = [
        # SCENARIO 3: Two External Monitors Connected (HDMI + DP)
        # Priority: HDMI is at 0,0 (Left/Primary), DP is to the right.
        # Internal screen (eDP-1) is disabled.
        {
          profile.name = "dual-external";
          profile.outputs = [
            {
              criteria = "LG Display 0x*";
              status = "disable";
            }
            {
              criteria = "HDMI-A-1";
              position = "0,0";
            }
            {
              criteria = "DP-1";
            }
          ];
        }

        # SCENARIO 2a: Only HDMI Connected
        {
          profile.name = "docked-hdmi";
          profile.outputs = [
            {
              criteria = "LG Display 0x*";
              status = "disable";
            }
            {
              criteria = "HDMI-A-1";
              position = "0,0";
            }
          ];
        }

        # SCENARIO 2b: Only DP Connected
        {
          profile.name = "docked-dp";
          profile.outputs = [
            {
              criteria = "LG Display 0x*";
              status = "disable";
            }
            {
              criteria = "DP-1";
              position = "0,0";
            }
          ];
        }

        # SCENARIO 1: No External (Undocked)
        {
          profile.name = "undocked";
          profile.outputs = [
            {
              criteria = "LG Display 0x*";
              status = "enable";
              mode = "1920x1080@144Hz";
              position = "0,0";
            }
          ];
        }

      ];
    };
}
