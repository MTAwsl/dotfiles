_: {
  flake.modules.features.redis = {
    services.redis.servers.default = {
      enable = true;
      bind = "127.0.0.1";
      port = 6379;
    };
  };
}
