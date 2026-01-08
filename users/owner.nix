{ config, ... }:
{
  flake.meta.owner = {
    username = "yuri";
    fullname = "Sayuri Nekomiya";
    email = "bbh@awsl.rip";
    uid = config.user.users.yuri.uid;
  };
}
