{ inputs, ... }:
let
  serviceName = "onedrive-index";
  serviceUser = serviceName;
  serviceGroup = serviceName;
  configDir = "/etc/${serviceName}";
  secretsDir = "/var/lib/${serviceName}";
  redisUrlFile = "${secretsDir}/redis-url";
  siteConfigFile = "${configDir}/site.config.js";
  apiConfigFile = "${configDir}/api.config.js";
in
{
  flake.modules.features.onedrive-index =
    { config, pkgs, ... }:
    let
      app = pkgs.buildNpmPackage (finalAttrs: {
        pname = "onedrive-vercel-index";
        version = "unstable-2023-06-23";

        src = inputs.onedrive-vercel-index;

        nativeBuildInputs = [ pkgs.pnpm_9 ];
        npmConfigHook = pkgs.pnpmConfigHook;
        npmDeps = finalAttrs.pnpmDeps;
        nodejs = pkgs.nodejs_22;

        pnpmDeps = pkgs.fetchPnpmDeps {
          inherit (finalAttrs) pname version src;
          fetcherVersion = 3;
          pnpm = pkgs.pnpm_9;
          hash = "sha256-Avsr3I+0Cf3vOsqUDkOHk1eo/LzNxWPEU60Cn24LWYg=";
        };

        env.NEXT_TELEMETRY_DISABLED = "1";

        installPhase = ''
          runHook preInstall

          mkdir -p "$out"
          cp -R \
            .next \
            config \
            next-i18next.config.js \
            next.config.js \
            node_modules \
            package.json \
            public \
            "$out"/

          runHook postInstall
        '';
      });
      appDir = "${app}";
      nextBin = "${appDir}/node_modules/next/dist/bin/next";
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
        home = secretsDir;
        description = "OneDrive Index service user";
        hashedPassword = "!";
        shell = "${pkgs.shadow}/bin/nologin";
      };

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
          ConfigurationDirectory = serviceName;
          ConfigurationDirectoryMode = "0700";
          StateDirectory = serviceName;
          StateDirectoryMode = "0700";
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
          BindReadOnlyPaths = [
            "${siteConfigFile}:${appDir}/config/site.config.js"
            "${apiConfigFile}:${appDir}/config/api.config.js"
          ];
          ReadWritePaths = [
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
