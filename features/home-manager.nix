{
  inputs,
  config,
  ...
}:
let
  home-manager-config =
    { lib, pkgs, ... }:
    {
      home-manager = {
        verbose = true;
        useUserPackages = true;
        useGlobalPkgs = true;
        extraSpecialArgs = {
          inherit (pkgs) yaziPluginsHomeModule;
        };
        backupFileExtension = "bak";
        backupCommand = "rm";
        overwriteBackup = true;
        sharedModules = [
          (
            {
              lib,
              ...
            }:
            {
              # isDesktopProfile option.
              options.home.isDesktopProfile = lib.mkOption {
                type = lib.types.bool;
                default = false;
              };
            }
          )
        ];
      };
    };
in
{
  flake.modules.nixos.home-manager = {
    imports = [
      inputs.home-manager.nixosModules.home-manager
      home-manager-config
    ];
  };

  flake.modules.darwin.home-manager = {
    imports = [
      inputs.home-manager.darwinModules.home-manager
      home-manager-config
    ];
  };

}
