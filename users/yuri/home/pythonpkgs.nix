_: {
  flake.modules.users.yuri.home.pythonpkgs =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        (python3.withPackages (
          python-pkgs: with python-pkgs; [
            # Devtools
            pandas
            numpy
            requests
            requests.optional-dependencies.socks
            pycryptodome
            argparse
            ipython
            # unicorn
            # angr
            # unicorn-angr
          ]
        ))

      ];

    };
}
