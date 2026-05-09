{ ... }:
{
  flake.modules.nixos.postgresql = {
    services.postgresql = {
      enable = true;
      enableTCPIP = false;
    };
  };
}
