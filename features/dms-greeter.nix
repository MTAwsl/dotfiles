{ self, ... }:
{
  flake.modules.features.dms-greeter = _: {
    services.displayManager.dms-greeter = {
      enable = true;
      compositor.name = "niri"; # Or "hyprland" or "sway"
      configHome = "/home/${self.lib.meta.owner.username}";
    };
  };
}
