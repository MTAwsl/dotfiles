{ inputs, ... }:
{
  flake.modules.users.yuri.home.opencode =
    { pkgs, config, ... }:
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
        package = pkgs.llm-agents.opencode;
        settings = {
          # FIX: Re-Enable after https://github.com/anomalyco/opencode/issues/27894 is closed.
          lsp = true;
          plugin = [ "@mohak34/opencode-notifier@latest" ];
          permission = {
            external_directory = {
              "/*" = "ask";
              "/nix/store" = "allow";
              "/nix/store/**" = "allow";
              "~/.config/opencode" = "allow";
              "~/.config/opencode/*" = "allow";
              "${config.home.homeDirectory}/.config/opencode" = "allow";
              "${config.home.homeDirectory}/.config/opencode/*" = "allow";
            };
            read = {
              "*" = "allow";
              "*.env" = "deny";
              "*.env.*" = "deny";
              "*.env.example" = "allow";
              "~/.config/opencode/*" = "allow";
              "${config.home.homeDirectory}/.config/opencode/*" = "allow";
            };
            edit = {
              "/nix/store" = "deny";
              "/nix/store/**" = "deny";
              "~/.config/opencode/*" = "deny";
              "${config.home.homeDirectory}/.config/opencode/*" = "deny";
            };
            bash = {
              "*" = "ask";
              "~/.config/opencode/*" = "allow";
              "${config.home.homeDirectory}/.config/opencode/*" = "allow";
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
