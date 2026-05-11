{ ... }:
let
  fireflyDataDir = "/opt/firefly-iii";
  importerDataDir = "/opt/firefly-iii-data-importer";
in
{
  flake.modules.nixos.firefly-iii =
    { config, ... }:
    let
      hostName = config.networking.hostName;
      fireflyUrl = "http://${hostName}";
      siteOwner = config.flake.lib.meta.owner.email;
    in
    {
      assertions = [
        {
          assertion = config.services.postgresql.enable;
          message = "features/firefly-iii.nix requires the postgresql feature to be imported and enabled.";
        }
      ];

      services.postgresql = {
        ensureDatabases = [ "firefly-iii" ];
        ensureUsers = [
          {
            name = "firefly-iii";
            ensureDBOwnership = true;
          }
        ];
      };

      services.firefly-iii = {
        enable = true;
        dataDir = fireflyDataDir;
        enableNginx = false;
        settings = {
          APP_URL = fireflyUrl;
          APP_KEY_FILE = "${fireflyDataDir}/app-key";
          DB_CONNECTION = "pgsql";
          DB_HOST = "/run/postgresql";
          DB_PORT = 5432;
          DB_DATABASE = "firefly-iii";
          DB_USERNAME = "firefly-iii";
          DB_PASSWORD_FILE = "${fireflyDataDir}/db-password";
          SITE_OWNER = siteOwner;
        };
      };

      services.firefly-iii-data-importer = {
        enable = false;
        dataDir = importerDataDir;
        enableNginx = false;
        settings = {
          APP_URL = fireflyUrl;
          FIREFLY_III_URL = fireflyUrl;
          FIREFLY_III_ACCESS_TOKEN_FILE = "${importerDataDir}/firefly-access-token";
        };
      };
    };
}
