# This flake module provides a minimum setup for my CLI environment
# that I am comfortable with for existing Linux systems (incl. WSL).
#
# It should not be activated with NixOS setups.
#
{ self, ... }:
let
  username = "yuri";
  users = self.lib.getUsers self.modules.users;
  user = users.${username};
  localZshRcFilename = ".zshrc.local.sh";
in
{
  flake.modules.users.yuri.profiles.hm-cli-workflow =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      imports = with user.home; [
        helix-theme
        zellij
        clitools
      ];

      home = {
        inherit username;
        homeDirectory = "/home/${username}";
        stateVersion = "26.05";
        packages = with pkgs; [
          gnupg
        ];

        activation = {
          ensureZshLocalRc = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
            if [ ! -f "${config.home.homeDirectory}/${localZshRcFilename}" ]; then
              echo "# Put your custom .zshrc configs here" > "${config.home.homeDirectory}/${localZshRcFilename}"
            fi
          '';
        };
      };

      programs = {
        home-manager.enable = true;
        zsh = {
          initContent = ''
            unsetopt BEEP # Disable Annoying BEEP sound on autocompletion.

            # PATH env variable for custom executables.
            export PATH="${config.home.homeDirectory}/.cargo/bin:$PATH"
            export PATH="${config.home.homeDirectory}/.bin:$PATH"
            export PATH="${config.home.homeDirectory}/.local/bin:$PATH"

            source ${config.home.homeDirectory}/${localZshRcFilename}
          '';
        };
      };
    };
}
