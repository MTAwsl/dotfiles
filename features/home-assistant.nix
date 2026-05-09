{ ... }:
{
  flake.modules.nixos.home-assistant =
    { ... }:
    {
      services.home-assistant = {
        enable = true;
        configDir = "/opt/home-assistant";
        openFirewall = true;

        config = {
          default_config = { };
          recorder = {
            commit_interval = 30;
            purge_keep_days = 5;
            auto_purge = true;
            auto_repack = true;
            exclude = {
              domains = [
                "automation"
                "update"
              ];
              entities = [
                "sensor.date"
                "sensor.last_boot"
              ];
            };
          };
        };
      };
    };
}
