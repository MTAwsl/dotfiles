_: {
  flake.modules.users.yuri.home.kanshiLayouts.lemonade = _: {
    services.kanshi.settings = [
      # Disable DP output
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
            status = "disable";
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
          {
            criteria = "DP-1";
            status = "disable";
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
          {
            criteria = "HDMI-A-1";
            position = "disable";
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
