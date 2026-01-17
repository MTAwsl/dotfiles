{ ... }:
{
  flake.modules.nixos.qemu-host =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        qemu
        quickemu
        dnsmasq
      ];

      systemd.tmpfiles.rules = [ "L+ /var/lib/qemu/firmware - - - - ${pkgs.qemu}/share/qemu/firmware" ];

      boot.binfmt.emulatedSystems = [
        "aarch64-linux"
        "riscv64-linux"
      ];

      virtualisation.libvirtd = {
        enable = true;
        qemu.vhostUserPackages = with pkgs; [ virtiofsd ];
        qemu.swtpm.enable = true;
      };
      programs.virt-manager.enable = true;
    };
}
