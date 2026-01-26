{ inputs, ... }:
{
  flake.modules.homeManager.yuri-yazi =
    { pkgs, ... }:
    {
      imports = [
        (inputs.nix-yazi-plugins.legacyPackages.x86_64-linux.homeManagerModules.default)
      ];

      home.packages = with pkgs; [ ];

      programs.yazi = {
        enable = true;
        enableBashIntegration = true;
        enableZshIntegration = true;

        plugins = with pkgs.yaziPlugins; {
          inherit vcs-files;
        };

        keymap.manager.prepend_keymap = [
          {
            on = [
              "g"
              "c"
            ];
            run = "plugin vcs-files";
            desc = "Show Git file changes";
          }
        ];

        yaziPlugins = {
          enable = true;
          plugins = {
            relative-motions = {
              enable = true;
              show_numbers = "relative_absolute";
              show_motion = true;
            };
            starship.enable = true;
            chmod.enable = true;
            smart-enter.enable = true;
            # vcs-files.enable = true; # Uncomment after https://github.com/lordkekz/nix-yazi-plugins/issues/37 added vcs.
            git.enable = true;
            full-border.enable = true;
          };
        };
      };

      programs.zsh.initContent = ''
        function yy() {
        	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
        	yazi "$@" --cwd-file="$tmp"
        	if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        		cd -- "$cwd"
        	fi
        	rm -f -- "$tmp"
        }
      '';
    };
}
