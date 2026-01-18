{ self, ... }:
{
  flake.modules.nixos.user-yuri-desktop =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      home-manager.users.yuri = {
        imports = with self.lib.withPrefix "yuri" self.modules.homeManager; [
          # kanshi
          niri
          dms-shell
          stylix
          qtgtk

          # Airpods on Linux
          librepods

          # Shell
          starship
          zellij

          firefox

          # i18n-rime-ice
          (
            { lib, ... }:
            {
              home.activation = {

                writeRimeConfig = lib.hm.dag.entryAfter [ "writeBoundry" ] ''
                  TARGET="$HOME/.local/share/fcitx5/rime/default.custom.yaml"

                  if [ ! -e "$TARGET" ]; then
                    mkdir -p "$(dirname "$TARGET")"
                    cat <<EOF > "$TARGET"
                  patch:
                    __include: rime_ice_suggestion:/

                  schema_list:
                    - schema: rime_ice
                  EOF

                  fi'';

                writeRimeData = lib.hm.dag.entryAfter [ "writeBoundry" ] ''
                  DEST="$HOME/.local/share/fcitx5/rime"
                  SRC="${pkgs.rime-ice}/share/rime-data"

                  if [ ! -d "$DEST" ]; then
                    mkdir -p "$DEST"
                  fi

                  ln -sfn "$SRC"/* "$DEST/"
                '';
              };
            }
          )
        ];

        home.packages = with pkgs; [

          # Screenshot
          # Switch back to flameshot once https://github.com/flameshot-org/flameshot/issues/3605 is closed.
          # flameshot
          grim # Use with Niri spawn-with-sh
          satty

          # apps
          audacity
          bitwarden-desktop
          bottles
          lutris
          filezilla
          swayimg
          # gale
          gimp
          gparted
          # heroic # Epic Games launcher
          inkscape-with-extensions
          obsidian
          piper
          protonup-qt
          qbittorrent
          # signal-desktop
          syncplay
          telegram-desktop
          # ventoy-full
          vesktop
          vlc
          zed-editor
          pear-desktop # YT Music
        ];

        programs = {
          vscode.enable = true;
          mpv.enable = true;
          obs-studio.enable = true;
        };

        # HyprIdle
        services.hypridle = {
          enable = true;
          settings = {
            general = {
              lock_cmd = "pidof hyprlock || hyprlock";
              before_sleep_cmd = "loginctl lock-session";
            };
            listener = [ ];
          };
        };
      };

      fonts.fontDir.enable = true;

      i18n.inputMethod = {
        enable = true;
        type = "fcitx5";
        fcitx5 = {
          waylandFrontend = true;
          addons = with pkgs; [
            kdePackages.fcitx5-qt
            fcitx5-fluent
            fcitx5-rime
            rime-ice
          ];
        };
      };

      # sound
      security.rtkit.enable = true;
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
      };

      # printing
      services.printing.enable = true;

      # the app that maximizes my retention
      programs.steam.enable = true;

      # controller
      # hardware.xone.enable = true;
      hardware.xpadneo.enable = true;

      # mouse config (piper)
      services.ratbagd.enable = true;
    };
}
