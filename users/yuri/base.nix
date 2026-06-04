{ self, ... }:
let
  username = "yuri";
  avatarPath = ./face.png;
  accountsServiceIconPath = "/var/lib/AccountsService/icons/${username}";
  users = self.lib.getUsers self.modules.users;
  user = users.${username};
in
{
  flake.modules.users.yuri.profiles.base =
    {
      config,
      pkgs,
      ...
    }:
    {
      services.accounts-daemon.enable = true;

      systemd.tmpfiles.rules = [
        "d /var/lib/AccountsService 0755 root root -"
        "d /var/lib/AccountsService/icons 0755 root root -"
        "C+ ${accountsServiceIconPath} 0644 root root - ${avatarPath}"
        "z ${accountsServiceIconPath} 0644 root root -"
      ];

      systemd.services."accountsservice-icon-${username}" = {
        description = "Set AccountsService icon for ${username}";
        requires = [ "accounts-daemon.service" ];
        after = [
          "accounts-daemon.service"
          "systemd-tmpfiles-setup.service"
        ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = pkgs.writeShellScript "accountsservice-icon-${username}" ''
            set -eu

            user_path="/org/freedesktop/Accounts/User${toString config.users.users.${username}.uid}"

            ${pkgs.dbus}/bin/dbus-send \
              --system \
              --print-reply \
              --dest=org.freedesktop.Accounts \
              "$user_path" \
              org.freedesktop.Accounts.User.SetIconFile \
              string:${accountsServiceIconPath} \
              >/dev/null
          '';
        };
      };

      users.users.yuri = {
        initialHashedPassword = "$2b$05$E6jMmkL6CzIotAr33rISt.TCmfPeexxU6iRM7zXtzmh6Cwfyrq17W";
        isNormalUser = true;
        uid = 1000;
        description = "Sayuri Nekomiya";
        shell = pkgs.zsh;
        extraGroups = [
          "networkmanager" # Risk accepted.
          "plugdev"
          "wheel"
        ];
        openssh.authorizedKeys.keys = [
          "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIPm8fm2GbPerlhMI4jwfjyg3HGIyql/n2XaMNHwHn8nTAAAABHNzaDo= Sayuri Nekomiya's YubiKey 5"
        ];
      };

      home-manager.users.${username} = {

        imports = with user.home; [
          stylix
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
