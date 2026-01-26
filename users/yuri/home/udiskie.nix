{ ... }:
{
  flake.modules.homeManager.yuri-udiskie =
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
