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
      bitwardenReadyCheck = "test -S ${bitwardenAgentSocket} && SSH_AUTH_SOCK=${bitwardenAgentSocket} ${pkgs.openssh}/bin/ssh-add -L >/dev/null 2>&1";
    in
    {
      programs.ssh = {
        enable = true;
        enableDefaultConfig = false;
        matchBlocks = {
          bitwarden-fallback = lib.hm.dag.entryBefore [ "*" ] (
            commonSshSettings
            // {
              match = ''exec "${bitwardenFallbackCheck} && ${bitwardenReadyCheck}"'';
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
