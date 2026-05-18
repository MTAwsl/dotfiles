{ ... }:
{
  perSystem =
    { final, pkgs, ... }:
    let
      version = "0.44.1";
      src = final.fetchFromGitHub {
        owner = "zellij-org";
        repo = "zellij";
        tag = "v${version}";
        hash = "sha256-KHpVUjuOmMtkt8qBaCozD3M44eEtDwFmdDfszKAz0bM=";
      };
    in
    {
      overlayAttrs.zellij = pkgs.zellij.overrideAttrs (_finalAttrs: _prevAttrs: {
        inherit version src;

        cargoDeps = final.rustPlatform.fetchCargoVendor {
          pname = "zellij";
          inherit version src;
          hash = "sha256-D3nZBXoGNf5z85iT7Xhj9Xwwwam/5m3X5hLPVoCzSPM=";
        };
      });
    };
}
