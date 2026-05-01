{ inputs, ... }:
{
  flake.modules.homeManager.yuri-opencode =
    { pkgs, ... }:
    {
      imports = [ inputs.oac-flake.homeManagerModules.oac ];

      home.packages = with pkgs; [
        libnotify
        pulseaudio
        alsa-utils
        mpv
        ffmpeg
      ];

      xdg.configFile."opencode/opencode.json".text = builtins.toJSON {
        plugin = [ "@mohak34/opencode-notifier@latest" ];
      };

      xdg.configFile."opencode/opencode-notifier.json".text = builtins.toJSON {
        sound = true;
        notification = true;
        suppressWhenFocused = true;
        timeout = 5;
        linux.grouping = false;
      };

      programs.opencode = {
        enable = true;
        tui = {
          theme = "opencode";
        };

        oac = {
          enable = true;
          profile = "advanced";
          installAdditionalPaths = true;
        };
      };
    };
}
