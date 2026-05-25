_: {
  perSystem =
    { inputs', ... }:
    let
      upstreamYaziPluginsHomeModule =
        inputs'.nix-yazi-plugins.legacyPackages.homeManagerModules.yaziPlugins;
    in
    {
      overlayAttrs.yaziPluginsHomeModule =
        { config, lib, ... }:
        let
          cfg = config.programs.yazi.yaziPlugins;
          vcsFilesCfg = cfg.plugins."vcs-files";
        in
        {
          imports = [
            upstreamYaziPluginsHomeModule
          ];

          # FIX: Remove once nix-yazi-plugins adds first-class vcs-files module support.
          options.programs.yazi.yaziPlugins.plugins."vcs-files" = {
            enable = lib.mkEnableOption "vcs-files";
            package = lib.mkOption {
              type = lib.types.nullOr lib.types.package;
              description = "The vcs-files package to use";
              default = config.programs.yazi.plugins."vcs-files" or null;
            };
            key = lib.mkOption {
              type = lib.types.submodule {
                options = {
                  on = lib.mkOption {
                    type = lib.types.listOf lib.types.str;
                    default = [
                      "g"
                      "c"
                    ];
                  };
                  run = lib.mkOption {
                    type = lib.types.str;
                    default = "plugin vcs-files";
                  };
                  desc = lib.mkOption {
                    type = lib.types.str;
                    default = "Show Git file changes";
                  };
                };
              };
              description = "Key binding for the vcs-files plugin";
              default = { };
            };
          };

          config = lib.mkMerge [
            # FIX: Remove once nix-yazi-plugins updated fetcher rules for Yazi v26.5.6+. (https://github.com/lordkekz/nix-yazi-plugins/issues/64)
            (lib.mkIf (cfg.enable && cfg.plugins.git.enable) {
              programs.yazi.settings.plugin.prepend_fetchers = lib.mkForce [
                {
                  url = "*";
                  run = "git";
                  group = "git";
                }
                {
                  url = "*/";
                  run = "git";
                  group = "git";
                }
              ];
            })
            (lib.mkIf (cfg.enable && vcsFilesCfg.enable && vcsFilesCfg.package != null) {
              programs.yazi = {
                plugins."vcs-files" = vcsFilesCfg.package;
                keymap.mgr.prepend_keymap = [ vcsFilesCfg.key ];
              };
            })
          ];
        };
    };
}
