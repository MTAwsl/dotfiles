# FIX: Remove this file once https://github.com/nixos/nixpkgs/issues/513245 is closed
_: {
  perSystem =
    { final, pkgs, ... }:
    let
      withOpenLdapNoCheck =
        pkg:
        pkg.override {
          buildFHSEnv =
            args:
            final.buildFHSEnv (
              args
              // {
                multiPkgs =
                  envPkgs:
                  let
                    originalPkgs = args.multiPkgs envPkgs;
                    customLdap = envPkgs.openldap.overrideAttrs (_: {
                      doCheck = false;
                    });
                  in
                  builtins.filter (p: (p.pname or "") != "openldap") originalPkgs ++ [ customLdap ];
              }
            );
        };
    in
    {
      overlayAttrs = {
        lutris = withOpenLdapNoCheck pkgs.lutris;
        bottles = withOpenLdapNoCheck pkgs.bottles;
      };
    };
}
