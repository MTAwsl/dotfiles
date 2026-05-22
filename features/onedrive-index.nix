_:
let
  serviceName = "onedrive-index";
  serviceUser = serviceName;
  serviceGroup = serviceName;
  serviceHome = "/opt/${serviceName}";
  appDir = "${serviceHome}/app";
  configDir = "${serviceHome}/config";
  secretsDir = "${serviceHome}/secrets";
  redisUrlFile = "${secretsDir}/redis-url";
  siteConfigFile = "${configDir}/site.config.js";
  apiConfigFile = "${configDir}/api.config.js";
  nextBin = "${appDir}/node_modules/next/dist/bin/next";
in
{
  flake.modules.features.onedrive-index =
    { config, pkgs, ... }:
    let
      launchScript = pkgs.writeShellApplication {
        name = "onedrive-index-launch";
        runtimeInputs = with pkgs; [
          bash
          coreutils
          nodejs_22
        ];
        text = ''
          set -euo pipefail

          readonly APP_DIR="${appDir}"
          readonly SITE_CONFIG_FILE="${siteConfigFile}"
          readonly API_CONFIG_FILE="${apiConfigFile}"
          readonly REDIS_URL_FILE="${redisUrlFile}"
          readonly NEXT_BIN="${nextBin}"

          test -f "$APP_DIR/package.json"
          test -f "$APP_DIR/.next/BUILD_ID"
          test -d "$APP_DIR/public"
          test -d "$APP_DIR/node_modules"
          test -f "$SITE_CONFIG_FILE"
          test -f "$API_CONFIG_FILE"
          test -f "$REDIS_URL_FILE"
          test -x "$NEXT_BIN"

          mkdir -p "$APP_DIR/config"
          ln -sfn "$SITE_CONFIG_FILE" "$APP_DIR/config/site.config.js"
          ln -sfn "$API_CONFIG_FILE" "$APP_DIR/config/api.config.js"

          REDIS_URL="$(< "$REDIS_URL_FILE")"
          export REDIS_URL
          export NODE_ENV="production"
          export HOSTNAME="127.0.0.1"
          export PORT="3000"

          cd "$APP_DIR"
          exec ${pkgs.nodejs_22}/bin/node "$NEXT_BIN" start --hostname "$HOSTNAME" --port "$PORT"
        '';
      };
    in
    {
      assertions = [
        {
          assertion = config.services.redis.servers.default.enable;
          message = "features/onedrive-index.nix requires the redis feature to be imported and enabled.";
        }
      ];

      users.groups.${serviceGroup} = { };

      users.users.${serviceUser} = {
        isSystemUser = true;
        group = serviceGroup;
        home = serviceHome;
        createHome = true;
        homeMode = "0700";
        description = "OneDrive Index service user";
        hashedPassword = "!";
        shell = "${pkgs.shadow}/bin/nologin";
      };

      systemd.tmpfiles.rules = [
        "d ${appDir} 0750 ${serviceUser} ${serviceGroup} -"
        "d ${configDir} 0700 ${serviceUser} ${serviceGroup} -"
        "d ${secretsDir} 0700 ${serviceUser} ${serviceGroup} -"
      ];

      systemd.services.onedrive-index = {
        description = "OneDrive Index";
        after = [
          "network-online.target"
          "redis-default.service"
        ];
        wants = [ "network-online.target" ];
        serviceConfig = {
          Type = "exec";
          User = serviceUser;
          Group = serviceGroup;
          WorkingDirectory = appDir;
          ExecStartPre = "${pkgs.coreutils}/bin/test -f ${appDir}/package.json";
          ExecStart = "${launchScript}/bin/onedrive-index-launch";
          Restart = "on-failure";
          RestartSec = "10s";
          TimeoutStartSec = "120s";
          TimeoutStopSec = "30s";
          NoNewPrivileges = true;
          PrivateTmp = true;
          PrivateDevices = true;
          ProtectSystem = "strict";
          ProtectHome = true;
          ProtectProc = "invisible";
          ReadWritePaths = [
            appDir
            configDir
            secretsDir
          ];
          ProtectKernelTunables = true;
          ProtectKernelModules = true;
          ProtectControlGroups = true;
          LockPersonality = true;
          MemoryDenyWriteExecute = true;
          RestrictSUIDSGID = true;
          UMask = "0077";
        };
      };
    };
}
