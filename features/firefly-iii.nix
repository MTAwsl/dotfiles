{ self, ... }:
let
  fireflyDataDir = "/opt/firefly-iii";
  importerDataDir = "/opt/firefly-iii-data-importer";
in
{
  flake.modules.features.firefly-iii =
    { config, lib, ... }:
    let
      hostName = config.networking.hostName;
      fireflyUrl = lib.mkDefault "http://${hostName}";
      siteOwner = self.lib.meta.owner.email;
    in
    {
      assertions = [
        {
          assertion = config.services.postgresql.enable;
          message = "features/firefly-iii.nix requires the postgresql feature to be imported and enabled.";
        }
      ];

      services = {
        postgresql = {
          ensureDatabases = [ "firefly-iii" ];
          ensureUsers = [
            {
              name = "firefly-iii";
              ensureDBOwnership = true;
            }
          ];
        };

        firefly-iii = {
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

        firefly-iii-data-importer = {
          enable = true;
          dataDir = importerDataDir;
          enableNginx = false;
          settings = {
            APP_URL = fireflyUrl;
            FIREFLY_III_URL = fireflyUrl;
            FIREFLY_III_ACCESS_TOKEN_FILE = "${importerDataDir}/firefly-access-token";
          };
        };
      };

      users.users.nginx.extraGroups = [
        "firefly-iii"
        "firefly-iii-data-importer"
      ];
    };
}
