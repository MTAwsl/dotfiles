{
  lib,
  ...
}:
{
  flake.modules.features.qemu-share-fs =
    _:
    let
      mount_point = "/mnt/share";
    in
    {
      fileSystems."${mount_point}" = {
        device = "share";
        fsType = "9p";
        options = [
          "trans=virtio"
          "version=9p2000.L"
          "rw"
          "_netdev"
          "nofail"
          "auto"
        ];
      };

      system.activationScripts.qemu-share-fs-ensure = {
        text = ''
          mkdir -p /mnt/${mount_point}
        '';
        deps = [ ];
      };
    };

  flake.lib.mkQemuShareBindFS =
    pkgs: username:
    let
      # Use ls -na to get host directory's UID and GID in guest.
      host_uid = builtins.toString 501;
      host_gid = builtins.toString 20;
      mount_point =
        if lib.strings.hasInfix "/" username then username else "/home/${username}/qemu-share";
    in
    {
      system.fsPackages = [ pkgs.bindfs ];

      fileSystems."${mount_point}" = {
        device = "/mnt/share";
        fsType = "fuse.bindfs";
        options = [
          "map=${host_uid}/${username}:@${host_gid}/@users"
          "map-passwd=/etc/passwd"
          "map-group=/etc/group"
          "x-systemd.requires=/mnt/share"
          "_netdev"
          "nofail"
          "auto"
        ];
      };

      system.activationScripts."qemu-share-fs-ensure-${username}" = {
        text = ''
          mkdir -p ${mount_point}
        '';
        deps = [ ];
      };
    };
}
