{ self, ... }:
{
  flake.modules.nixos.profile-qemu-guest =
    { ... }:
    {
      imports = with self.modules.nixos; [
        qemu-share-fs
      ];

      services.spice-autorandr.enable = true;
      services.spice-vdagentd.enable = true;

      # If using webdavd, enable this.
      services.spice-webdavd.enable = false;

      services.qemuGuest.enable = true;
    };
}
