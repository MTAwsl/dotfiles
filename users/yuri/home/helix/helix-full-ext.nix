{ self, ... }:
{
  flake.modules.users.yuri.home.helix-full-ext = _: {
    imports = with self.modules.users.yuri.home; [
      helix-packages
      helix-languages
    ];

    programs.helix.enable = true;
  };
}
