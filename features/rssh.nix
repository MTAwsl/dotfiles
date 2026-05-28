_: {
  flake.modules.features.rssh = _: {

    security.pam.rssh.enable = true;

    # Specifically enable it for the sudo service
    security.pam.services.sudo.rssh = true;

    # Ensure the SSH agent socket is preserved when switching to root
    security.sudo.extraConfig = ''
      Defaults env_keep += "SSH_AUTH_SOCK"
    '';
  };
}
