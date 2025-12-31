{ self, ... }:
{
  flake.modules.nixos.dms-shell =
    { ... }:
    {
      programs.dms-shell = {
        enable = true;
        systemd = {
          enable = true; # Systemd service for auto-start
          restartIfChanged = true; # Auto-restart dms.service when dms-shell changes
        };

        # Core features
        enableSystemMonitoring = true; # System monitoring widgets (dgop)
        enableClipboard = true; # Clipboard history manager
        enableVPN = true; # VPN management widget
        enableDynamicTheming = true; # Wallpaper-based theming (matugen)
        enableAudioWavelength = true; # Audio visualizer (cava)
        enableCalendarEvents = true; # Calendar integration (khal)
      };

      services.displayManager.dms-greeter = {
        enable = true;
        compositor.name = "niri"; # Or "hyprland" or "sway"
        configHome = "/home/${self.meta.owner.username}";
      };
    };
}
