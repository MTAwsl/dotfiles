{ pkgs, ... }:
final: prev:
let
  withOpenLdapNoCheck = pkg:
    pkg.override {
      buildFHSEnv =
        args:
        pkgs.buildFHSEnv (
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
  # FIX: Remove once https://github.com/nixos/nixpkgs/issues/513245 is closed
  lutris = withOpenLdapNoCheck prev.lutris;

  # FIX: Remove once https://github.com/nixos/nixpkgs/issues/513245 is closed
  bottles = withOpenLdapNoCheck prev.bottles;
}
