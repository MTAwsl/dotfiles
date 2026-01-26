{ ... }:
{
  flake.modules.homeManager.yuri-keepassxc =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        keepassxc-go
      ];
      programs.keepassxc = {
        autostart = true;
        enable = true;
        settings = {
          FdoSecrets.Enabled = true;
          SSHAgent.Enabled = true;
          Browser.Enabled = true;
          GUI.ApplicationTheme = "dark";
        };
      };
      xdg.autostart.enable = true;
    };
}
