# FIX: Remove once https://github.com/NixOS/nixpkgs/pull/420793 is merged.
_: {
  perSystem =
    { pkgs, ... }:
    {
      overlayAttrs = {
        john = pkgs.john.overrideAttrs (_old: {
          src = pkgs.fetchFromGitHub {
            owner = "openwall";
            repo = "john";
            rev = "f514ece8ec4ae5e38ad75aaa322eac86d73dcd76";
            hash = "sha256-zO1/KUJe3LvYCGlwVpNg5uDwPRD0ql/7anErb7tywC0=";
          };
        });
      };
    };
}
