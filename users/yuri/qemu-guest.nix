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
        (self.lib.mkQemuShareBindFS pkgs "yuri" 1000)
      ];

      home-manager.users.yuri = {
        home.packages = [
          pkgs.uniclip
        ];

        # Spawn SPICE agent on QEMU Guests
        programs.niri.settings = {
          spawn-at-startup = [
            { sh = "spice-vdagent"; }
            # {
            #   sh = "while true; do timeout 2m uniclip ${self.meta.qemu-host.ip}:${self.meta.qemu-host.uniclip-port}; if [[ $? -ne 124 ]]; then sleep 5; fi; done";
            # }
          ];
        };
      };
    };
}
