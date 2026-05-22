_: {
  flake.modules.features.earlyoom = {
    services.earlyoom = {
      enable = true;
      freeMemThreshold = 5;
      freeSwapThreshold = 5;
    };
  };
}
