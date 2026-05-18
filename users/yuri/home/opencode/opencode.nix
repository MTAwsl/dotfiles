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

      xdg.configFile."opencode/opencode-notifier.json".text = builtins.toJSON {
        sound = true;
        notification = true;
        suppressWhenFocused = false;
        timeout = 5;
        linux.grouping = false;
      };

      programs.opencode = {
        enable = true;
        settings = {
          plugin = [ "@mohak34/opencode-notifier@latest" ];
          permission = {
            external_directory = {
              "/*" = "ask";
              "~/.config" = "deny";
              "~/.config/**" = "deny";
              "~/.config/opencode" = "allow";
              "~/.config/opencode/**" = "allow";
              "/nix/store" = "allow";
              "/nix/store/**" = "allow";
            };
            read = {
              "*" = "allow";
              "*.env" = "deny";
              "*.env.*" = "deny";
              "*.env.example" = "allow";
            };
            edit = {
              "~/.config/opencode" = "ask";
              "~/.config/opencode/**" = "ask";
              "/nix/store" = "deny";
              "/nix/store/**" = "deny";
            };
            bash = {
              "*" = "ask";
              "pwd" = "allow";
              "ls" = "allow";
              "ls *" = "allow";
              "wc" = "allow";
              "wc *" = "allow";
              "jq" = "allow";
              "jq *" = "allow";
              "rg" = "allow";
              "rg *" = "allow";
              "ast-grep" = "allow";
              "ast-grep *" = "allow";
              "sg" = "allow";
              "sg *" = "allow";
              "file" = "allow";
              "file *" = "allow";
              "stat" = "allow";
              "stat *" = "allow";
              "tree" = "allow";
              "tree *" = "allow";
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
              "nix --impure" = "deny";
              "nix --impure *" = "deny";
              "nix * --impure" = "deny";
              "nix * --impure *" = "deny";
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
