_: {
  perSystem =
    { config, inputs', ... }:
    {
      overlayAttrs = {
        uniclip = inputs'.uniclip.packages.uniclip;
        pwndbg = inputs'.pwndbg.packages.default;
        bloodhound-cli = inputs'.bloodhound-cli.packages.default;
        librepods = inputs'.nix-librepods-bin.packages.default;
        local = config.packages;
      };
    };
}
