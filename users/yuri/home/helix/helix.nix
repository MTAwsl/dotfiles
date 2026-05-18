{ self, ... }:
{
  flake.modules.users.yuri.home.helix = _: {
    imports = with self.modules.users.yuri.home; [
      helix-packages
      helix-editor
      helix-languages
    ];

    programs.helix.enable = true;
  };
}
