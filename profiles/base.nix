{ self, ... }: {
  flake.modules.profiles.base =
    { pkgs, ... }:
    {
      imports = with self.modules.features; [
        stylix
      ];

      environment.systemPackages = with pkgs; [
        file
        vim
        fzf
        git
        wget
        prettier
        helix
        htop

        # System monitor
        iw
        pciutils
        usbutils
      ];

      security.polkit.enable = true;
      networking.networkmanager.plugins = with pkgs; [
        networkmanager-l2tp
        networkmanager-openconnect
        networkmanager-openvpn
        networkmanager-ssh
      ];
      networking.firewall.checkReversePath = "loose"; # Fix VPN connections.

      users.groups.plugdev = { };
      systemd.settings.Manager.DefaultTimeoutStopSec = "10s";
      systemd.user.extraConfig = ''
        DefaultTimeoutStopSec=10s
      '';

      programs = {
        git = {
          enable = true;
        };

        yazi = {
          enable = true;
        };

        nix-ld.enable = true;
        bat.enable = true;
        zsh = {
          enable = true;
          ohMyZsh = {
            enable = true;
            preLoaded = ''
              zstyle ':omz:update' mode disabled
            '';
          };

          autosuggestions.enable = true;
          syntaxHighlighting.enable = true;

          shellAliases = {
            cat = "bat";
          };
        };
      };
    };
}
