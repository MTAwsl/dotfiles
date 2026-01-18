{ lib, ... }:
{
  # Credit: qiront/nixconf
  flake.modules.homeManager.yuri-zsh =
    {
      config,
      pkgs,
      ...
    }:
    {
      home.packages = with pkgs; [
        eza
        difftastic
      ];

      programs = {
        zsh = {
          enable = true;
          # zprof.enable = true;

          oh-my-zsh = {
            enable = true;
            extraConfig = ''
              zstyle ':omz:update' mode disabled
            '';
          };

          autosuggestion.enable = true;
          syntaxHighlighting.enable = true;

          shellAliases = {
            cat = "bat";
            diff = "difft";
            ls = "eza";
            fzhx = "hx $(fzf)";
          };

          initContent = ''
            # Autosuggest
            bindkey '^I'   complete-word       # tab          | complete
            bindkey '^[[Z' autosuggest-accept  # shift + tab  | autosuggest
            ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(buffer-empty bracketed-paste accept-line push-line-or-edit)
            ZSH_AUTOSUGGEST_STRATEGY=(history completion)
            ZSH_AUTOSUGGEST_USE_ASYNC=true

            # pnpm
            export PNPM_HOME="${config.home.homeDirectory}/.local/share/pnpm"
            case ":$PATH:" in
              *":$PNPM_HOME:"*) ;;
              *) export PATH="$PNPM_HOME:$PATH" ;;
            esac
            # pnpm end

            # editor
            export EDITOR="hx"
            export VISUAL="$EDITOR"
          '';
        };

        # use zoxide to replace cd
        zoxide = {
          enable = true;
          options = [ "--cmd cd" ];
        };

        # file explorer
        yazi = {
          enable = true;
          enableBashIntegration = true;
          enableZshIntegration = true;
        };

        # the cat replacement that actually does something
        bat.enable = true;

        # great file fuzzy finder
        fzf.enable = true;

        atuin = {
          enable = true;
          settings = {
            update_check = false;
            auto_sync = true; # remember to login with `atuin login -u <USERNAME>`
            enter_accept = true;
            filter_mode_shell_up_key_binding = "session";
            style = "compact";
          };
        };

        direnv = {
          enable = true;
          nix-direnv.enable = true;
        };

      };
    };

}
