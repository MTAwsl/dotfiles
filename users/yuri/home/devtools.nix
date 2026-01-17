{ ... }:
{
  flake.modules.homeManager.yuri-devtools =
    { pkgs, ... }:
    {

      home.packages = with pkgs; [
        # Node JS and LSP.
        nodejs
        nodePackages."typescript"
        astro-language-server

        rustc
        cargo

        go

        # Python
        uv
        (python3.withPackages (
          python-pkgs: with python-pkgs; [
            pandas
            numpy
            requests
            pycryptodome
            argparse
            ipython
          ]
        ))

        gcc
        gdb
        cmake
        autoconf
        automake
      ];

    };
}
