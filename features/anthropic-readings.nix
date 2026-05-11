{
  inputs,
  ...
}:
let
  serviceName = "anthropic-readings";
  serviceUser = serviceName;
  serviceGroup = serviceName;
  serviceHome = "/opt/${serviceName}";
  configFile = "${serviceHome}/config.yaml";
in
{
  flake.modules.nixos.anthropic-readings = { pkgs, ... }: let
    package = inputs.anthropic-readings.packages.${pkgs.stdenv.hostPlatform.system}.default;
  in {
    users.groups.${serviceGroup} = { };

    users.users.${serviceUser} = {
      isSystemUser = true;
      group = serviceGroup;
      home = serviceHome;
      createHome = true;
      homeMode = "0700";
      description = "Anthropic Readings service user";
      hashedPassword = "!";
      shell = "${pkgs.shadow}/bin/nologin";
    };

    systemd.services.anthropic-readings = {
      description = "Anthropic Readings";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      serviceConfig = {
        Type = "oneshot";
        User = serviceUser;
        Group = serviceGroup;
        WorkingDirectory = serviceHome;
        ExecStartPre = "${pkgs.coreutils}/bin/test -f ${configFile}";
        ExecStart = "${package}/bin/anthropic-readings-daemon --once --config ${configFile}";
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        ReadWritePaths = [ serviceHome ];
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectControlGroups = true;
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
      };
    };

    systemd.timers.anthropic-readings = {
      description = "Run Anthropic Readings every 12 hours";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "1h";
        OnUnitInactiveSec = "12h";
        Unit = "anthropic-readings.service";
      };
    };
  };
}
