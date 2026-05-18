{
  self,
  ...
}:
let
  username = "yuri";
in
{
  flake.modules.users.yuri.profiles.qemu-guest =
    {
      pkgs,
      ...
    }:
    {
      imports = with self.modules.features; [
        (self.lib.mkQemuShareBindFS pkgs username)
      ];

      home-manager.users.${username} = {
        home.packages = [
          pkgs.uniclip
        ];

        # Spawn SPICE agent on QEMU Guests
        programs.niri.settings = {
          spawn-at-startup = [
            { sh = "spice-vdagent"; }
            {
              sh = "app2unit -s s -t service -d \"Uniclip-rs clipboard sharing\" -p Restart=always -p RestartSec=5 -- uniclip-rs -p ${self.lib.meta.qemu-host.ip}:${self.lib.meta.qemu-host.uniclip-port}";
            }
          ];
        };
      };
    };
}
