{ self, ... }:
{
  flake.modules.nixos.user-yuri =
    {
      pkgs,
      lib,
      ...
    }:
    {
      users.users.yuri = {
        initialHashedPassword = "$2b$05$E6jMmkL6CzIotAr33rISt.TCmfPeexxU6iRM7zXtzmh6Cwfyrq17W";
        isNormalUser = true;
        description = "Sayuri Nekomiya";
        extraGroups = [
          "networkmanager"
          "wheel"
        ];
      };

      home-manager.users.yuri = {
        imports = with self.lib.withPrefix "yuri" self.modules.homeManager; [
          git
          yazi
          helix
        ];

        home = {
          username = "yuri";
          homeDirectory = "/home/yuri";
          stateVersion = "26.05";
          packages = with pkgs; [
            nodejs
            nodePackages."typescript"
            astro-language-server
          ];
        };

        programs = {
          home-manager.enable = true;
        };
      };
    };
}
