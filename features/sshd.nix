_: {
  flake.modules.features.sshd = {
    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
        PubkeyAuthentication = true;
      };
    };

    networking.firewall.allowedTCPPorts = [ 22 ];
  };
}
