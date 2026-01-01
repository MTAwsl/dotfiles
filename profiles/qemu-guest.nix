{ ... }:
{
  flake.modules.nixos.profile-qemu-guest =
    { ... }:
    {
      services.spice-autorandr.enable = true;
      services.spice-vdagentd.enable = true;

      # If using webdavd, enable this.
      services.spice-webdavd.enable = true;

      services.qemuGuest.enable = true;
    };
}
