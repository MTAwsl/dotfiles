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
        ffmpeg-full
      ];

      xdg.configFile."opencode/opencode.json".text = builtins.toJSON {
        plugin = [ "@mohak34/opencode-notifier@latest" ];
        permission = {
          external_directory = {
            "~/.config" = "deny";
            "~/.config/**" = "deny";
            "~/.config/opencode" = "allow";
            "~/.config/opencode/**" = "allow";
            "/nix/store" = "allow";
            "/nix/store/**" = "allow";
          };
          read = {
            "~/.config/opencode" = "allow";
            "~/.config/opencode/**" = "allow";
            "/nix/store" = "allow";
            "/nix/store/**" = "allow";
          };
          edit = {
            "~/.config/opencode" = "ask";
            "~/.config/opencode/**" = "ask";
            "/nix/store" = "ask";
            "/nix/store/**" = "ask";
          };
          bash = {
            "*" = "ask";
            "pwd" = "allow";
            "ls" = "allow";
            "ls *" = "allow";
            "git status" = "allow";
            "git status *" = "allow";
            "git diff" = "allow";
            "git diff *" = "allow";
            "git log" = "allow";
            "git log *" = "allow";
            "git show" = "allow";
            "git show *" = "allow";
            "git branch" = "allow";
            "git branch *" = "allow";
            "git rev-parse" = "allow";
            "git rev-parse *" = "allow";
            "nix" = "allow";
            "nix *" = "allow";
            "sudo" = "deny";
            "sudo *" = "deny";
            "rm" = "deny";
            "rm *" = "deny";
            "nixos-rebuild" = "deny";
            "nixos-rebuild *" = "deny";
            "nh" = "deny";
            "nh *" = "deny";
            "nix run" = "deny";
            "nix run *" = "deny";
          };
        };
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
