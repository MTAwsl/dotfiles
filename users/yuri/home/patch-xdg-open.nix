{ ... }:
{
  flake.modules.homeManager.yuri-patch-xdg-open =
    { pkgs, ... }:
    {
      home.packages = [
        (pkgs.writeShellScriptBin "xdg-open" ''
          export XDG_CURRENT_DESKTOP=GNOME
          ${pkgs.xdg-utils}/bin/xdg-open $@
        '')
      ];
    };
}
