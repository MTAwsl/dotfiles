_:
{
  flake.modules.users.yuri.home.yazi =
    { inputs', pkgs, ... }:
    {
      imports = [
        inputs'.nix-yazi-plugins.legacyPackages.homeManagerModules.default
      ];

      home.packages = with pkgs; [ ];

      programs.yazi = {
        enable = true;
        enableBashIntegration = true;
        enableZshIntegration = true;
        shellWrapperName = "yy";

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
            vcs-files.enable = true;
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
