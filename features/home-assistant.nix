_: {
  flake.modules.features.home-assistant =
    { lib, pkgs, ... }:
    {
      services.home-assistant = {
        enable = true;
        configDir = "/opt/home-assistant";
        openFirewall = false;
        extraComponents = [
          # normal UI integrations
          "adguard"
          "switchbot"
          "seventeentrack"
          "bluetooth"
          "accuweather"
          "met"

          # Apple-related; choose what you actually need
          "icloud" # Apple iCloud account / device tracker
          "homekit" # expose HA entities to Apple Home
          "homekit_controller" # import HomeKit devices into HA
          "weatherkit" # Apple WeatherKit; needs Apple Developer account
          "apple_tv"

          # Thread / Matter
          "otbr"
          "thread"
          "matter"

          # usually useful basics
          "default_config"
          "zeroconf"
          "isal"

          "google_translate"
          "tts"

          "upnp"
          "unifi"
          "unifiprotect"

          "broadlink"
        ];

        extraPackages = ps: with ps; [
          setuptools
          packaging
        ];

        config = lib.mkForce null;
      };
    };
}
