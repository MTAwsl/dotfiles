{ ... }:
{
  flake.modules.homeManager.yuri-yubikey-ssh-agent =
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
      yubikeyIdentityFile = "${homeDirectory}/.ssh/id_ed25519_sk";
      yubikeyHosts = [ ];
    in
    {
      programs.ssh = {
        enable = true;
        enableDefaultConfig = false;
        matchBlocks = {
          "*" = {
            forwardAgent = false;
            addKeysToAgent = "no";
            compression = false;
            serverAliveInterval = 0;
            serverAliveCountMax = 3;
            hashKnownHosts = false;
            userKnownHostsFile = "~/.ssh/known_hosts";
            controlMaster = "no";
            controlPath = "~/.ssh/master-%r@%n:%p";
            controlPersist = "no";
            identityAgent = bitwardenAgentSocket;
          };
        } // lib.optionalAttrs (yubikeyHosts != [ ]) {
          "${lib.concatStringsSep " " yubikeyHosts}" = {
            identityAgent = yubikeyAgentSocket;
            identitiesOnly = true;
            identityFile = yubikeyIdentityFile;
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
