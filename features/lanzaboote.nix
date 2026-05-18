{
  inputs,
  lib,
  ...
}:
{
  # From https://github.com/QiroNT/nixconf.
  flake.modules.features.lanzaboote =
    { pkgs, ... }:
    {
      imports = [ inputs.lanzaboote.nixosModules.lanzaboote ];

      boot = {
        # secure boot, see lzbt & arch docs for setup
        loader = {
          efi.canTouchEfiVariables = lib.mkForce false;
          systemd-boot.enable = lib.mkForce false;
        };

        lanzaboote = {
          enable = true;
          pkiBundle = "/var/lib/sbctl";
          autoGenerateKeys.enable = true;
          autoEnrollKeys.enable = true;
        };

        # to roll disk encryption keys into TPM, use the following:
        # $ systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=7 --wipe-slot=tpm2 /dev/sdX
        # TODO add pcr 11 after https://github.com/nix-community/lanzaboote/issues/348
        initrd.systemd.enable = true;
      };

      environment.systemPackages = [ pkgs.sbctl ];
    };
}
