{ self, ... }:
{
  flake.modules.nixos.user-yuri-desktop =
    {
      lib,
      pkgs,
      ...
    }:
    {
      imports = with self.modules.nixos; [
        wireshark
      ];

      users.users.yuri = {
        extraGroups = [ "wireshark" ];
      };

      home-manager.users.yuri = {
        imports =
          with self.lib.withPrefix "yuri" self.modules.homeManager;
          [
            kanshi
            niri
            dms-shell
            stylix
            qtgtk

            devtools

            udiskie
            # keepassxc

            # Shell
            starship
            zellij

            # Vibe
            opencode

            firefox

            # XDG Default APPS
            xdg
            patch-xdg-open

            gh-release-tracker

            rime-ice
          ]
          ++ lib.optionals pkgs.stdenv.hostPlatform.isx86_64 [
            sectools
          ]
          ++ lib.optionals pkgs.stdenv.hostPlatform.isx86_64 [
            librepods
          ];

        home.isDesktopProfile = true;
        home.packages =
          with pkgs;
          (lib.optionals pkgs.stdenv.hostPlatform.isx86_64 [
            # Yubikey manager
            yubioath-flutter

            # Gaming stack packages with x86_64-only dependencies.
            bottles
            lutris
            protonup-qt
          ])
          ++ [
            # apps
            audacity
            bitwarden-desktop # This is unstable. For now do not lock the vault, see https://github.com/bitwarden/clients/issues/18463
            filezilla
            swayimg
            # gale
            gimp
            # heroic # Epic Games launcher
            inkscape-with-extensions
            obsidian
            piper
            qbittorrent
            # signal-desktop
            syncplay
            telegram-desktop
            # ventoy-full
            vesktop
            vlc
            zed-editor
            pear-desktop # YT Music
            zip
            unzip
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

      services.onedrive.enable = false;

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

      # Steam requires x86_64 userspace support.
      programs.steam = lib.mkIf pkgs.stdenv.hostPlatform.isx86_64 {
        # the app that maximizes my retention
        enable = true;
        extraCompatPackages = with pkgs; [
          # Let ProtonUp manages it
          # proton-ge-bin
        ];
      };
    };
}
