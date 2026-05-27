# FIX: Remove this file after https://github.com/numtide/llm-agents.nix/issues/5207 is closed.
_: {
  perSystem =
    { inputs', pkgs, ... }:
    {
      overlayAttrs.llm-agents.opencode = inputs'.llm-agents.packages.opencode.overrideAttrs (
        old:
        let
          version = "1.15.11";
          hashes = {
            aarch64-darwin = "sha256-+C8L2yhYNpccY2d90Y1wBduvRr/QTiI4OQW/hFP024w=";
            x86_64-darwin = "sha256-P9VPFWNwki2CZ+q2HvbrUyEQY5xbgtgkNeQ3wu53hGA=";
            x86_64-linux = "sha256-STFyU3IsaYOUmA4ZIf8o6RnXm7KdXD9M8xSkra9wN80=";
            aarch64-linux = "sha256-k+Q5nzCMSTh8JewrVwYCvw+d1fV5iUJ5RsDCjb8ln/Q=";
          };
          platformMap = {
            x86_64-linux = {
              asset = "opencode-linux-x64.tar.gz";
              isZip = false;
            };
            aarch64-linux = {
              asset = "opencode-linux-arm64.tar.gz";
              isZip = false;
            };
            x86_64-darwin = {
              asset = "opencode-darwin-x64.zip";
              isZip = true;
            };
            aarch64-darwin = {
              asset = "opencode-darwin-arm64.zip";
              isZip = true;
            };
          };
          platform = pkgs.stdenv.hostPlatform.system;
          platformInfo = platformMap.${platform} or (throw "Unsupported system: ${platform}");
        in
        {
          inherit version;
          src = pkgs.fetchurl {
            url = "https://github.com/anomalyco/opencode/releases/download/v${version}/${platformInfo.asset}";
            hash = hashes.${platform};
          };
        }
      );
    };
}
