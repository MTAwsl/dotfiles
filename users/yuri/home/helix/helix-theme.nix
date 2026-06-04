# This modules can be imported to set the theme when stylix is unavailable.
#
_: {
  flake.modules.users.yuri.home.helix-theme = _: {
    programs.helix.settings = {
      theme = "monokai"; # Managed by stylix
    };
  };
}
