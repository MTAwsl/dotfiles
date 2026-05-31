{ self, ... }:
let
  username = "yuri";
  users = self.lib.getUsers self.modules.users;
  user = users.${username};
in
{
  flake.modules.users.yuri.profiles.desktop =
    {
      lib,
      pkgs,
      ...
    }:
    {
      imports = with self.modules.features; [
        wireshark
      ];

      users.users.${username} = {
        extraGroups = [ "wireshark" ];
      };

      home-manager.users.${username} = {
        imports =
          (with user.home; [
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

            firefox

            # Vibe
            ai-tools

            # XDG Default APPS
            xdg
            patch-xdg-open

            gh-release-tracker

            rime-ice
            ssh-agent

            # Full Helix Config
            helix
          ])
          ++ lib.optionals pkgs.stdenv.hostPlatform.isx86_64 (with user.home; [ sectools ])
          ++ lib.optionals pkgs.stdenv.hostPlatform.isx86_64 (with user.home; [ librepods ]);

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
            pear-desktop # YT Music
            zip
            unzip
          ];

        programs = {
          vscode.enable = true;
          mpv.enable = true;
          obs-studio.enable = true;
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
