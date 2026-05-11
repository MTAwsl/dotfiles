{ self, ... }:
{
  flake.modules.nixos.user-yuri-base =
    {
      pkgs,
      lib,
      ...
    }:
    {
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
          ssh-agent
          yazi
          helix
          zsh
          starship
          clitools
          sys-update-prompt
        ];

        home = {
          username = "yuri";
          homeDirectory = "/home/yuri";
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
