{ ... }:
{
  flake.modules.nixos.nginx = {
    services.nginx = {
      enable = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
    };
  };
}
