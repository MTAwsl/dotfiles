{
  self,
  ...
}:
{
  flake.modules.nixos.user-yuri-qemu-guest =
    {
      pkgs,
      ...
    }:
    {
      imports = with self.modules.nixos; [
        (self.lib.mkQemuShareBindFS pkgs "yuri")
      ];

      home-manager.users.yuri = {
        home.packages = [
          pkgs.uniclip
        ];

        # Spawn SPICE agent on QEMU Guests
        programs.niri.settings = {
          spawn-at-startup = [
            { sh = "spice-vdagent"; }
            {
              sh = "app2unit -s s -t service -d \"Uniclip-rs clipboard sharing\" -p Restart=always -p RestartSec=5 -- uniclip-rs -p ${self.meta.qemu-host.ip}:${self.meta.qemu-host.uniclip-port}";
            }
          ];
        };
      };
    };
}
