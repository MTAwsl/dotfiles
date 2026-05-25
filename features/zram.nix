_: {
  flake.modules.features.zram = {
    zramSwap = {
      enable = true;
      algorithm = "zstd";
      priority = 100;
      memoryPercent = 50;
    };
  };
}
