# Source from: https://github.com/NixOS/nixpkgs/pull/377902
# FIX: Remove this file after chip-ota-provider-app is in nixpkgs (https://github.com/NixOS/nixpkgs/pull/377902 is merged, or via other commits)
{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  libnl,
}:

let
  srcInfo =
    {
      x86_64-linux = {
        filename = "chip-ota-provider-app-x86-64";
        hash = "sha256-RVDfevZSnkYgRj0cASf4MOwkBMgXrUxjQ7KeMs7AFE4=";
      };
      aarch64-linux = {
        filename = "chip-ota-provider-app-aarch64";
        hash = "sha256-4GirbEBQ4j6qbM2pv37M3Et5KiUU4QmMvBK0FM1kqn4=";
      };
    }
    .${stdenv.hostPlatform.system} or (throw "unsupported system ${stdenv.hostPlatform.system}");
in
stdenv.mkDerivation (finalAttrs: {
  pname = "chip-ota-provider-app";
  version = "2025.9.0";

  src = fetchurl {
    url = "https://github.com/home-assistant-libs/matter-linux-ota-provider/releases/download/${finalAttrs.version}/${srcInfo.filename}";
    hash = srcInfo.hash;
  };

  dontUnpack = true;
  dontBuild = true;

  nativeBuildInputs = [ autoPatchelfHook ];

  buildInputs = [
    libnl
    stdenv.cc.cc.lib
  ];

  installPhase = ''
    runHook preInstall

    install -Dm755 $src $out/bin/chip-ota-provider-app

    runHook postInstall
  '';

  meta = {
    description = "Matter OTA (Over-the-Air) firmware update provider application";
    homepage = "https://github.com/home-assistant-libs/matter-linux-ota-provider";
    changelog = "https://github.com/home-assistant-libs/matter-linux-ota-provider/releases/tag/${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ newam ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
})
