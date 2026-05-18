{ self, ... }:
{
  flake.modules.profiles.qemu-guest = _: {
    imports = with self.modules.features; [
      qemu-share-fs
    ];

    services = {
      spice-autorandr.enable = true;
      spice-vdagentd.enable = true;

      # If using webdavd, enable this.
      spice-webdavd.enable = false;

      qemuGuest.enable = true;
    };
  };
}
