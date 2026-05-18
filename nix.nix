_: {
  flake.modules.features.nix = _: {
    nix = {

      settings = {
        # enable flakes support
        experimental-features = [
          "nix-command"
          "flakes"
          "pipe-operators"
        ];

        sandbox = true;

        trusted-users = [ "root" ];

        substituters = [
          "https://cache.numtide.com"
          "https://cache.garnix.io"
          "https://nix-community.cachix.org"
          "https://numtide.cachix.org"
          "https://niri.cachix.org"
          "https://pwndbg.cachix.org"
          "https://attic.xuyh0120.win/lantian" # nix-cachyos-kernel
        ];
        trusted-public-keys = [
          "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
          "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
          "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
          "pwndbg.cachix.org-1:HhtIpP7j73SnuzLgobqqa8LVTng5Qi36sQtNt79cD3k="
          "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
        ];

        narinfo-cache-positive-ttl = 3600;
      };

      optimise.automatic = true;
      gc = {
        automatic = true;
        persistent = true;
        dates = "monthly";
        randomizedDelaySec = "45min";
        options = "--delete-older-than 30d";
      };
    };
  };
}
