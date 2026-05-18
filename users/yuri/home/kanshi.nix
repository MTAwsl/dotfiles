_: {
  flake.modules.users.yuri.home.kanshi = _: {
    services.kanshi = {
      enable = true;
      systemdTarget = "graphical-session.target";
    };
  };
}
