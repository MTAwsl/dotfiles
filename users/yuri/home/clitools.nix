{ inputs, ... }:
{
  flake.modules.homeManager.yuri-clitools =
    { config, pkgs, ... }:
    {

      imports = [ inputs.nix-index-database.homeModules.nix-index ];

      # Credit to my neighbour qiront:nixconf
      home.packages = with pkgs; [
        # Package development
        nix-update

        # CLI data fmt parser
        jq
        yj

        fastfetch
        htop
        btop

        # Invoke-WebRequest
        wget
        curl
        aria2
        yt-dlp

        rsync
        rclone

        # zip
        xz
        zstd
        brotli
        p7zip

        # multimedia
        ffmpeg-full
        imagemagick
        flac
        libheif
        libwebp
        optipng

        # ifconfig
        iperf
        tailscale
        inetutils

        # fuse
        ifuse
        mtools
        nfs-utils

        # DDOS tools (ohno, that's a joke)
        # nmap
        # wrk
        # oha

        # Misc
        rime-cli
        psmisc

        # tldr
        tlrc

        coreutils-full
        parallel

        fd
        eza
        dua
        ripgrep
        ast-grep
      ];

      services.tldr-update = {
        enable = true;
        package = pkgs.tlrc;
      };

      programs = {
        fzf = {
          enable = true;
          enableBashIntegration = true;
          enableZshIntegration = true;
          colors = {
            bg = "-1";
            "bg+" = "-1";
          };
          defaultCommand = "fd --type f";
          fileWidgetCommand = "fd --type f";
          fileWidgetOptions = [
            "--preview 'bat --style=numbers --color=always --line-range :500 {}'"
          ];
        };

        nh = {
          enable = true;
          flake = "${config.home.homeDirectory}/.config/nix-config";
        };

        direnv = {
          enable = true;
          nix-direnv.enable = true;
        };

        # file explorer
        yazi = {
          enable = true;
          enableBashIntegration = true;
          enableZshIntegration = true;
        };

        nix-index.enable = true; # command-not-found
        nix-index-database.comma.enable = true; # , -> nix run nixpkgs#
      };
    };
}
