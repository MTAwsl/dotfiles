{ self, ... }:
{
  flake.modules.nixos.dms-greeter =
    { ... }:
    {
      services.displayManager.dms-greeter = {
        enable = true;
        compositor.name = "niri"; # Or "hyprland" or "sway"
        configHome = "/home/${self.lib.meta.owner.username}";
      };
    };
}
