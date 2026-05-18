{ self, ... }:
{
  flake.modules.homeManager.yuri-helix =
    { ... }:
    {
      imports = with self.lib.withPrefix "yuri" self.modules.homeManager; [
        helix-packages
        helix-editor
        helix-languages
      ];

      programs.helix.enable = true;
    };
}
