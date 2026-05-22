_: {
  flake.modules.features.zram = {
    zramSwap = {
      enable = true;
      memoryPercent = 50;
    };
  };
}
