{ self, ... }:
{
  flake.modules.users.yuri.home.helix-simple = _: {
    imports = with self.modules.users.yuri.home; [
      helix-editor
    ];

    programs.helix.enable = true;
  };
}
