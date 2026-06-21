_: {
  perSystem =
    { config, inputs', ... }:
    {
      overlayAttrs = {
        uniclip = inputs'.uniclip.packages.uniclip;
        pwndbg = inputs'.pwndbg.packages.default;
        bloodhound-cli = inputs'.bloodhound-cli.packages.default;
        opencode = inputs'.opencode-bin.packages.opencode;
        local = config.packages;
      };
    };
}
