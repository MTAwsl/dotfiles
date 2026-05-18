{ ... }:
{
  perSystem =
    { config, inputs', ... }:
    {
      overlayAttrs = {
        uniclip = inputs'.uniclip.packages.uniclip;
        yaziPluginsHomeModule = inputs'.nix-yazi-plugins.legacyPackages.homeManagerModules.yaziPlugins;
        pwndbg = inputs'.pwndbg.packages.default;
        bloodhound-cli = inputs'.bloodhound-cli.packages.default;
        librepods = inputs'.nix-librepods-bin.packages.default;
        local = config.packages;
      };
    };
}
