{ config, lib, pkgs, ... }:
let
  homeDirectory = config.home.homeDirectory;
  bitwardenAgentSocket = "${homeDirectory}/.bitwarden-ssh-agent.sock";
  yubikeyAgentSocket = "${homeDirectory}/.ssh-agent.socket";
  yubikeyIdentityFile = "${homeDirectory}/.ssh/id_ed25519_sk";
  yubikeyHosts = [ ];

  yubikeyHostBlock =
    if yubikeyHosts == [ ] then
      ""
    else
      ''
        Host ${lib.concatStringsSep " " yubikeyHosts}
          IdentityAgent ${yubikeyAgentSocket}
          IdentitiesOnly yes
          IdentityFile ${yubikeyIdentityFile}
      '';
in
{
  flake.modules.homeManager.yuri-yubikey-ssh-agent = {
    programs.ssh = {
      enable = true;
      extraConfig = ''
        Host *
          IdentityAgent ${bitwardenAgentSocket}
      '' + yubikeyHostBlock;
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
