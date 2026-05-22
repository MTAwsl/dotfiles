_: {
  flake.modules.users.deployer.profiles.base =
    { pkgs, ... }:
    {
      users.users.deployer = {
        isNormalUser = true;
        description = "Remote NixOS deployment user";
        shell = pkgs.bashInteractive;
        hashedPassword = "!";
        openssh.authorizedKeys.keys = [
          "no-pty,no-X11-forwarding,no-agent-forwarding,no-port-forwarding sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIPm8fm2GbPerlhMI4jwfjyg3HGIyql/n2XaMNHwHn8nTAAAABHNzaDo= Sayuri Nekomiya's YubiKey 5"
        ];
      };

      nix.settings.trusted-users = [
        "deployer"
      ];
    };
}
