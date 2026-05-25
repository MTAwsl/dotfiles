# FIX: Remove once https://github.com/numtide/llm-agents.nix/issues/5170 is closed.
_: {
  perSystem =
    { lib, pkgs, ... }:
    {
      overlayAttrs.llm-agents = pkgs.llm-agents // {
        opencode = pkgs.llm-agents.opencode.overrideAttrs (oldAttrs: {
          installPhase = ''
            runHook preInstall

            mkdir -p $out/bin
            install -m755 opencode $out/bin/opencode

            wrapProgram $out/bin/opencode \
              --prefix PATH : ${
                lib.makeBinPath [
                  pkgs.fzf
                  pkgs.ripgrep
                ]
              } \
              --set LD_LIBRARY_PATH "${lib.makeLibraryPath [ pkgs.stdenv.cc.cc.lib ]}"
          '';
        });
      };
    };
}
