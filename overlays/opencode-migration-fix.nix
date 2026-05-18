# FIX: Remove once https://github.com/anomalyco/opencode/pull/21056 is merged and packaged.
{ ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      overlayAttrs.opencode = pkgs.opencode.overrideAttrs (oldAttrs: {
        postPatch = (oldAttrs.postPatch or "") + ''
          substituteInPlace packages/opencode/src/index.ts \
            --replace-fail 'import path from "path"' "" \
            --replace-fail 'import { Global } from "@opencode-ai/core/global"' "" \
            --replace-fail 'const marker = path.join(Global.Path.data, "opencode.db")' '// Use the database path as the marker to trigger migration if missing' \
            --replace-fail 'if (!(await Filesystem.exists(marker))) {' 'if (!(await Filesystem.exists(Database.Path))) {'
        '';
      });
    };
}
