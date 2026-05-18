_: {
  flake.modules.users.yuri.home.kde-connect = _: {
    programs.niri.settings.spawn-at-startup = [
      { sh = "kdeconnect-indicator &"; }
    ];

    services.kdeconnect.enable = false;
  };
}
