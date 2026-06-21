# FIX: Remove this file after flameshot v14 is released and is in nixpkgs-release
_: {
  perSystem =
    { inputs', ... }:
    {
      overlayAttrs.flameshot = inputs'.flameshot.packages.flameshot;
    };
}
