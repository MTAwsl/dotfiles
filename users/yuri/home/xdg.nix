{ lib, ... }:
{
  flake.modules.users.yuri.home.xdg =
    { pkgs, ... }:
    {
      home.packages = [
        # Write x-terminal-emulator to support terminal apps.
        (pkgs.writeShellScriptBin "x-terminal-emulator" ''
          exec ${pkgs.ghostty}/bin/ghostty "$@"
        '')
      ];
      xdg = {
        terminal-exec = {
          enable = true;
          settings = {
            default = [ "com.mitchellh.ghostty.desktop" ];
          };
        };

        mimeApps = {
          enable = true;

          defaultApplications =
            let
              imageTypes = [
                "jpeg"
                "png"
                "gif"
                "webp"
                "tiff"
                "bmp"
                "svg+xml"
              ];
              textTypes = [
                "plain"
                "markdown"
                "x-shellscript"
                "x-nix"
              ];
              applicationTextTypes = [
                "json"
                "toml"
                "yaml"
              ];
              videoTypes = [
                "mp4"
                "x-matroska"
                "webm"
                "quicktime"
                "x-msvideo"
                "mpeg"
              ];

              webSchemeTypes = [
                "http"
                "https"
                "about"
                "unknown"
              ];

              mkType =
                name: types: handler:
                let
                  isString = o: (builtins.typeOf o) == "string";
                  handlerList = if (isString handler) then [ handler ] else handler;
                  typesList = if (isString types) then [ types ] else types;
                in
                typesList |> (map (t: lib.nameValuePair (name + "/" + t) handlerList)) |> lib.listToAttrs;
            in
            lib.foldl' lib.mergeAttrs { } [
              (mkType "image" imageTypes "swayimg.desktop")
              (mkType "text" textTypes "dev.zed.Zed.desktop")
              (mkType "application" applicationTextTypes "dev.zed.Zed.desktop")
              (mkType "video" videoTypes [
                "vlc.desktop"
                "mpv.desktop"
              ])
              (mkType "x-scheme-handler" webSchemeTypes "firefox-devedition.desktop")

              # Firefox
              {
                "text/html" = [ "firefox-devedition.desktop" ];
                "application/pdf" = [ "firefox-devedition.desktop" ];
              }
            ];

        };
        portal = {
          enable = true;
          extraPortals = with pkgs; [
            xdg-desktop-portal-gtk
            xdg-desktop-portal-gnome
          ];
          config = {
            common.default = [
              "gnome"
              "gtk"
            ];
            niri = {
              default = [
                "gnome"
                "gtk"
              ];
            };
          };
        };
      };
    };
}
