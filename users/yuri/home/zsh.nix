_: {
  # Credit: qiront/nixconf
  flake.modules.users.yuri.home.zsh =
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
          dotDir = config.home.homeDirectory;
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
            ssh-no-keychk = "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null";
            sftp-no-keychk = "sftp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null";
            scp-no-keychk = "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null";
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

            # Rebind FZF
            bindkey -r "^T"
            bindkey "^F" fzf-file-widget

          '';
        };

        # use zoxide to replace cd
        zoxide = {
          enable = true;
          options = [ "--cmd cd" ];
        };

        # the cat replacement that actually does something
        bat.enable = true;

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
      };
    };

}
