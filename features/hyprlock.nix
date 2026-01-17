{ ... }:
{
  flake.modules.nixos.hyprlock =
    { ... }:
    {
      programs.hyprlock.enable = true;
    };
}
