{ lib, ... }:
{
  flake.modules.users.yuri.home.ripgrep =
    { config, pkgs, ... }:
    {
      home.packages = with pkgs; [
        ripgrep
      ];

      programs.zsh.initContent = ''
        export RIPGREP_CONFIG_PATH="${config.home.homeDirectory}/.ripgreprc"
      '';

      home.file.".ripgreprc".text = ''
        # Ignore hidden files and directories
        --hidden

        # Ignore version control folders like .git and .hg
        --glob=!.git/

        # Smartcase by default
        --smart-case

        # Max columns setting
        --max-columns=150
        --max-columns-preview
      '';
    };
}
