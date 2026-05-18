_: {
  flake.modules.users.yuri.home.udiskie =
    { pkgs, ... }:
    {

      services.udiskie = {
        enable = true;
        settings = {
          program_options = {
            file_manager = "${pkgs.nautilus}/bin/nautilus";
          };
        };
      };
    };
}
