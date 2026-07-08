# This flake module provides a minimum full setup for my CLI environment
# that I am comfortable with for existing Linux systems (incl. WSL).
#
# It should not be activated with NixOS setups.
#
{ self, ... }:
let
  username = "yuri";
  users = self.lib.getUsers self.modules.users;
  user = users.${username};
in
{
  flake.modules.users.yuri.profiles.hm-cli-workflow-full =
    {
      ...
    }:
    {
      imports =
        with user.profiles;
        [
          hm-cli-workflow
        ]
        ++ (with user.home; [
          helix-full-ext
        ]);
    };
}
