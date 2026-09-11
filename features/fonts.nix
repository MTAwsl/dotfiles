_: {
  flake.modules.features.fonts =
    { pkgs, ... }:
    {
      fonts.packages = with pkgs; [
        # Open/licensed replacements for formerly disabled Microsoft fonts:
        # - liberation_ttf: Arial / Times New Roman / Courier New metrics
        # - carlito: Calibri metrics
        # - caladea: Cambria metrics
        # - cascadia-code/source-code-pro: Consolas-style monospace coverage
        # - roboto/inter/dejavu_fonts: Segoe UI, Tahoma, Verdana, Georgia-style UI/text fallbacks
        # - material-symbols/font-awesome: Segoe Fluent/MDL2 icon-style fallbacks
        liberation_ttf
        carlito
        caladea
        cascadia-code
        source-code-pro
        roboto
        inter
        dejavu_fonts
        material-symbols
        font-awesome

        open-sans
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-cjk-serif
        noto-fonts-color-emoji
        source-han-sans
        source-han-serif
        geist-font

        fira-code
        fira-code-symbols
        monaspace
        nerd-fonts.fira-code
      ];
    };
}
