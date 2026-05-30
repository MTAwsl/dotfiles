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
        requires = [ "network-online.target" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "simple";
          User = serviceUser;
          Group = serviceGroup;
          Restart = "always";
          WorkingDirectory = serviceHome;
          ExecStartPre = "${pkgs.coreutils}/bin/test -f ${configFile}";
          ExecStart = "${package}/bin/msgraph-health-sentinel --config ${configFile}";
          RestartSec = "300s";
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
    };
}
