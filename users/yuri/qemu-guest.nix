{ self, inputs, ... }:
{
  flake.modules.nixos.user-yuri-qemu-guest =
    {
      pkgs,
      ...
    }:
    {
      home-manager.users.yuri = {
        home.packages = [
          inputs.uniclip.packages.${pkgs.stdenv.hostPlatform.system}.uniclip
        ];

        # Spawn SPICE agent on QEMU Guests
        programs.niri.settings = {
          spawn-at-startup = [
            { sh = "spice-vdagent"; }
            {
              sh = "while true; do timeout 2m uniclip ${self.meta.qemu-host.ip}:${self.meta.qemu-host.uniclip-port}; if [[ $? -ne 124 ]]; then sleep 5; fi; done";
            }
          ];
        };
      };
    };
}
