{ config, ... }:
{
  flake.lib.meta.owner = {
    username = "yuri";
    fullname = "Sayuri Nekomiya";
    email = "bbh@awsl.rip";
    uid = config.user.users.yuri.uid;
    pam_origin = "MiniSoda";
    github-ssh-pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN8RLUKnpdMAFQ7gPa/YJV2PsiE//Kn3Ub6dsx8b+i9H";
  };
}
