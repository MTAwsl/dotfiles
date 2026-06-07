# FIX: Remove this file once nixpkgs-unstable includes https://github.com/NixOS/nixpkgs/pull/528460 for https://github.com/nixos/nixpkgs/issues/525683.
_: {
  perSystem =
    { pkgs, ... }:
    {
      overlayAttrs.firefoxpwa-unwrapped = pkgs.firefoxpwa-unwrapped.overrideAttrs (old: {
        postInstall =
          (old.postInstall or "")
          + ''

            # Create empty `lib/firefoxpwa` directory so the Firefox wrapper won't fail
            # trying to disable the update checks. It will try to write to
            # `$out/lib/firefoxpwa/is-packaged-app`, which doesn't exist by default.
            mkdir -p $out/lib/firefoxpwa
          '';
      });
    };
}
