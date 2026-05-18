{ inputs, ... }:
{
  flake.modules.users.yuri.home.dms-shell =
    _:
    let
      USERNAME = "yuri";
    in
    {
      imports = [
        inputs.dms.homeModules.dank-material-shell
        inputs.dms.homeModules.niri
      ];

      programs.dank-material-shell = {
        # Do not define settings here unless a declearative config is required.
        # Or the settings will be overwritten.
        enable = true;
        niri = {
          enableKeybinds = false; # Sets static preset keybinds
          enableSpawn = true; # Auto-start DMS with niri, if enabled
          includes = {
            enable = true;
            override = false;
            filesToInclude = [
              "alttab"
              "colors"
              "wpblur"
              "cursor"
              "outputs"
              "layout"
              # "binds"
            ];
          };
        };
      };

      home.activation.ensureDmsNiriIncludes = ''
        if [ ! -d "/home/${USERNAME}/.config/niri/dms" ]; then
          mkdir -p ~/.config/niri/dms
        fi

        if [ ! -f "/home/${USERNAME}/.config/niri/dms/cursor.kdl" ]; then
          touch /home/${USERNAME}/.config/niri/dms/cursor.kdl
        fi

        if [ ! -f "/home/${USERNAME}/.config/niri/dms/outputs.kdl" ]; then
          touch /home/${USERNAME}/.config/niri/dms/outputs.kdl
        fi
      '';
    };
}
