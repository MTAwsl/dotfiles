{ self, ... }:
let
  username = "yuri";
  avatarPath = ./face.png;
  accountsServiceIconPath = "/var/lib/AccountsService/icons/${username}";
in
{
  flake.modules.nixos.user-yuri-base =
    {
      pkgs,
      lib,
      ...
    }:
    {
      services.accounts-daemon.enable = true;

      systemd.tmpfiles.rules = [
        "d /var/lib/AccountsService/icons 0755 root root -"
        "d /var/lib/AccountsService/users 0755 root root -"
        "L+ ${accountsServiceIconPath} - - - - ${avatarPath}"
        "f+ /var/lib/AccountsService/users/${username} 0644 root root - [User]\nIcon=${accountsServiceIconPath}"
      ];

      users.users.yuri = {
        initialHashedPassword = "$2b$05$E6jMmkL6CzIotAr33rISt.TCmfPeexxU6iRM7zXtzmh6Cwfyrq17W";
        isNormalUser = true;
        uid = 1000;
        description = "Sayuri Nekomiya";
        shell = pkgs.zsh;
        extraGroups = [
          "networkmanager" # Risk accepted.
          "wheel"
        ];
        openssh.authorizedKeys.keys = [
          "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIPm8fm2GbPerlhMI4jwfjyg3HGIyql/n2XaMNHwHn8nTAAAABHNzaDo= Sayuri Nekomiya's YubiKey 5"
        ];
      };

      home-manager.users.yuri = {

        imports = with self.lib.withPrefix "yuri" self.modules.homeManager; [
          git
          git-commit-helpers
          ssh-agent
          yazi
          helix
          zsh
          starship
          clitools
          sys-update-prompt
        ];

        home = {
          inherit username;
          homeDirectory = "/home/${username}";
          stateVersion = "26.05";
          packages = with pkgs; [
            gnupg
          ];

          # User Avatar (Optional)
          file.".face" = {
            source = ./face.png;
          };
        };

        programs = {
          home-manager.enable = true;
        };
      };
    };
}
