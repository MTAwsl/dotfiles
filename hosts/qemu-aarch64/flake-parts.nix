{ inputs, lib, ... }:
{
  flake.nixosConfigurations.qemu-aarch64 = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      inputs.self.modules.nixos.host-qemu-aarch64
      {
        nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
      }
    ];
  };
}
