_: {
  flake.modules.features.nginx = {
    services.nginx = {
      enable = true;
      recommendedTlsSettings = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
    };
  };
}
