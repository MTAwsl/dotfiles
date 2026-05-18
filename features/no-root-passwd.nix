_: {
  flake.modules.features.no-root-passwd = _: {
    users.users.root.hashedPassword = "!";
  };
}
