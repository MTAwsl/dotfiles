# FIX: Remove this file after https://github.com/NixOS/nixpkgs/issues/386392 is closed.
_: {
  perSystem =
    { pkgs, ... }:
    {
      overlayAttrs.pam_ssh_agent_auth = pkgs.pam_ssh_agent_auth.overrideAttrs (
        old:
        if pkgs.stdenv.isAarch64 then
          {
            postFixup = (old.postFixup or "") + ''
              ${pkgs.patchelf}/bin/patchelf \
                --add-needed libgcc_s.so.1 \
                --add-rpath ${pkgs.stdenv.cc.cc.lib}/lib \
                $out/libexec/pam_ssh_agent_auth.so
            '';
          }
        else
          { }
      );
    };
}
