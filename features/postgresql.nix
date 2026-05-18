_: {
  flake.modules.features.postgresql = {
    services.postgresql = {
      enable = true;
      enableTCPIP = false;
    };
  };
}
