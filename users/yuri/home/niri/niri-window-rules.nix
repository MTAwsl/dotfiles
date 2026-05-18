_: {
  flake.modules.users.yuri.home.niri-window-rules = {
    programs.niri.settings.window-rules = [
      {
        geometry-corner-radius = {
          bottom-left = 6.;
          bottom-right = 6.;
          top-left = 6.;
          top-right = 6.;
        };
        clip-to-geometry = true;
        tiled-state = true;
        draw-border-with-background = false;
      }
      {
        matches = [
          { app-id = "^firefox-devedition$"; }
          { app-id = "Bitwarden"; }
        ];
        open-on-workspace = "1";
      }
      {
        matches = [
          {
            app-id = "org.gnome.Nautilus";
            is-active = true;
          }
        ];
        opacity = 0.95;
      }
      {
        matches = [
          { app-id = "org.quickshell$"; }
        ];
        open-floating = true;
      }
      {
        matches = [
          {
            app-id = "^com.mitchellh.ghostty$";
            at-startup = true;
          }
        ];
        open-on-workspace = "2";
        default-column-width.proportion = 0.3;
      }
      {
        matches = [
          { app-id = "^org.telegram.desktop$"; }
          { app-id = "^vesktop$"; }
        ];
        open-on-workspace = "3";
      }
      {
        matches = [
          { app-id = "com.mitchellh.ghostty"; }
        ];
        draw-border-with-background = false;
        default-column-width.proportion = 0.3;
      }
      {
        matches = [
          {
            app-id = "steam";
            title = "^notificationtoasts_\\d+_desktop$";
          }
        ];
        default-floating-position = {
          x = 10;
          y = 10;
          relative-to = "top-right";
        };
        open-focused = false;
      }
      {
        matches = [
          {
            app-id = "com.mitchellh.ghostty";
            is-active = false;
          }
        ];
        opacity = 0.95; # stylix already made ghostty opaque.
        draw-border-with-background = false;
        default-column-width.proportion = 0.3;
      }
      {
        matches = [
          { is-active = false; }
        ];
        opacity = 0.85;
      }
    ];
  };
}
