{ ... }:
{
  flake.modules.nixos.no-root-passwd = { ... }: {
    users.users.root.hashedPassword = "!";
  };
}
