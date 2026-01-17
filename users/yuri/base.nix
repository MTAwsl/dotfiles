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
          "networkmanager"
          "wheel"
          "input"
          "plugdev"
        ];
      };

      home-manager.users.yuri = {
        imports = with self.lib.withPrefix "yuri" self.modules.homeManager; [
          git
          yazi
          helix
          zsh
          starship
          clitools
          devtools
        ];

        home = {
          username = "yuri";
          homeDirectory = "/home/yuri";
          stateVersion = "26.05";
        };

        # User Avatar
        # I recommend to set it up otherwise DMS may becomes laggy.
        home.file.".face" = {
          source = ./face.png;
        };

        programs = {
          home-manager.enable = true;
        };
      };
    };
}
