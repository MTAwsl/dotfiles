_: {
  flake.modules.users.yuri.home.tmux = _: {
    programs.tmux = {
      enable = true;
      shortcut = "a";
      baseIndex = 1;
      historyLimit = 20000;

      extraConfig = ''
        # Start panes at 1 (line 3)
        setw -g pane-base-index 1

        # Enable mouse control (line 7)
        set -g mouse on

        # Vim-style pane selection keys
        bind-key h select-pane -L
        bind-key j select-pane -D
        bind-key k select-pane -U
        bind-key l select-pane -R

        # Remap splitting keys
        unbind '"'
        unbind %
        bind = split-window -h
        bind - split-window -v

        # Load Nix Shell
        set-option -g default-command "env -u __ETC_PROFILE_NIX_SOURCED $SHELL"
      '';
    };
  };
}
