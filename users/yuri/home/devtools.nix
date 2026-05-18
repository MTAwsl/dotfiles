_: {
  flake.modules.users.yuri.home.devtools =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        # Node JS and LSP.
        nodejs
        typescript
        astro-language-server

        rustc
        cargo

        dotnet-sdk

        go

        # Python
        uv
        (python3.withPackages (
          python-pkgs: with python-pkgs; [
            pandas
            numpy
            requests
            requests.optional-dependencies.socks
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

      # uv's custom python bin path.
      home.sessionPath = [ "/home/yuri/.local/bin" ];
    };
}
