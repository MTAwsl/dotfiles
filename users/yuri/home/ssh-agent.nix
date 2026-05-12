{ ... }:
{
  flake.modules.homeManager.yuri-ssh-agent =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      homeDirectory = config.home.homeDirectory;
      bitwardenAgentSocket = "${homeDirectory}/.bitwarden-ssh-agent.sock";
      yubikeyAgentSocket = "${homeDirectory}/.ssh-agent.socket";
      yubikeyPrivateKeyFile = "${homeDirectory}/.ssh/id_ed25519_sk";
      commonSshSettings = {
        forwardAgent = true;
        addKeysToAgent = "no";
        compression = false;
        serverAliveInterval = 0;
        serverAliveCountMax = 3;
        hashKnownHosts = false;
        userKnownHostsFile = "~/.ssh/known_hosts";
        controlMaster = "no";
        controlPath = "~/.ssh/master-%r@%n:%p";
        controlPersist = "no";
      };
      bitwardenFallbackCheck = "test ! -S ${yubikeyAgentSocket} || ! SSH_AUTH_SOCK=${yubikeyAgentSocket} ${pkgs.openssh}/bin/ssh-add -L >/dev/null 2>&1";
      bitwardenMatchScript = pkgs.writeShellScript "ssh-bitwarden-match" ''
        if ! ${bitwardenFallbackCheck}; then
          exit 1
        fi

        if ! test -S ${bitwardenAgentSocket}; then
          exit 1
        fi

        if SSH_AUTH_SOCK=${bitwardenAgentSocket} ${pkgs.coreutils}/bin/timeout 5s ${pkgs.openssh}/bin/ssh-add -L >/dev/null 2>&1; then
          exit 0
        fi

        if [ "$?" -eq 124 ]; then
          printf '\033[1;33mwarning:\033[0m Bitwarden SSH agent did not respond within 5 seconds; continuing with YubiKey agent.\n' >&2
        fi

        exit 1
      '';
      yubikeyAgentBootstrapScript = pkgs.writeShellScript "ssh-agent-fido-bootstrap" ''
        for _ in 1 2 3 4 5 6 7 8 9 10; do
          if test -S ${yubikeyAgentSocket}; then
            break
          fi

          sleep 0.5
        done

        if ! test -S ${yubikeyAgentSocket} || ! test -f ${yubikeyPrivateKeyFile}; then
          exit 0
        fi

        if ! SSH_AUTH_SOCK=${yubikeyAgentSocket} ${pkgs.coreutils}/bin/timeout 5s ${pkgs.openssh}/bin/ssh-add ${yubikeyPrivateKeyFile} >/dev/null 2>&1; then
          printf '\033[1;33mwarning:\033[0m Failed to add YubiKey SSH key to agent automatically.\n' >&2
        fi
      '';
    in
    {
      programs.ssh = {
        enable = true;
        enableDefaultConfig = false;
        matchBlocks = {
          bitwarden-fallback = lib.hm.dag.entryBefore [ "*" ] (
            commonSshSettings
            // {
              match = ''exec "${bitwardenMatchScript}"'';
              identityAgent = bitwardenAgentSocket;
              identitiesOnly = false;
            }
          );
          "*" = commonSshSettings // {
            identityAgent = yubikeyAgentSocket;
            identitiesOnly = true;
            identityFile = yubikeyPrivateKeyFile;
          };
        };
      };

      systemd.user.services.ssh-agent-fido = {
        Unit = {
          Description = "OpenSSH agent for YubiKey-backed FIDO2 keys";
        };

        Service = {
          Type = "simple";
          ExecStartPre = "${pkgs.coreutils}/bin/rm -f ${yubikeyAgentSocket}";
          ExecStart = "${pkgs.openssh}/bin/ssh-agent -D -a ${yubikeyAgentSocket}";
          ExecStartPost = yubikeyAgentBootstrapScript;
          Restart = "on-failure";
          RestartSec = "5s";
          NoNewPrivileges = true;
          PrivateTmp = true;
        };

        Install = {
          WantedBy = [ "default.target" ];
        };
      };
    };
}
