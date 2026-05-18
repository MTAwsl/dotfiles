{
  inputs,
  ...
}:
let
  serviceName = "msgraph-health-sentinel";
  serviceUser = serviceName;
  serviceGroup = serviceName;
  serviceHome = "/opt/${serviceName}";
  configFile = "${serviceHome}/config.json";
in
{
  flake.modules.features.msgraph-health-sentinel =
    { pkgs, ... }:
    let
      package = inputs.msgraph-health-sentinel.packages.${pkgs.stdenv.hostPlatform.system}.default;
    in
    {
      users.groups.${serviceGroup} = { };

      users.users.${serviceUser} = {
        isSystemUser = true;
        group = serviceGroup;
        home = serviceHome;
        createHome = true;
        homeMode = "0700";
        description = "MSGraph Health Sentinel service user";
        hashedPassword = "!";
        shell = "${pkgs.shadow}/bin/nologin";
      };

      systemd.services.msgraph-health-sentinel = {
        description = "MSGraph Health Sentinel";
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        serviceConfig = {
          Type = "oneshot";
          User = serviceUser;
          Group = serviceGroup;
          WorkingDirectory = serviceHome;
          ExecStartPre = "${pkgs.coreutils}/bin/test -f ${configFile}";
          ExecStart = "${package}/bin/msgraph-health-sentinel --once --config ${configFile}";
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

      systemd.timers.msgraph-health-sentinel = {
        description = "Run MSGraph Health Sentinel every 10 to 20 minutes";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnBootSec = "10m";
          OnUnitInactiveSec = "10m";
          RandomizedDelaySec = "10m";
          Unit = "msgraph-health-sentinel.service";
        };
      };
    };
}
