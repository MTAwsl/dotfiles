_: {
  flake.modules.features.ssh-agent-auth = _: {

    security.pam.sshAgentAuth.enable = true;

    # Specifically enable it for the sudo service
    security.pam.services.sudo.sshAgentAuth = true;

    # Ensure the SSH agent socket is preserved when switching to root
    security.sudo.extraConfig = ''
      Defaults env_keep += "SSH_AUTH_SOCK"
    '';
  };
}
