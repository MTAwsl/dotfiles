{ self, lib, ... }:
{
  config.flake.lib.getUsers =
    users:
    lib.mapAttrs (
      username: user:
      let
        home = user.home or { };
      in
      {
        profiles = user.profiles or { };
        inherit home;
        homeModules = lib.mapAttrs (_moduleName: homeModule: _: {
          home-manager.users.${username}.imports = [ homeModule ];
        }) (removeAttrs home [ "kanshiLayouts" ]);
        kanshiLayouts = lib.mapAttrs (_layoutName: layoutModule: _: {
          home-manager.users.${username}.imports = [ layoutModule ];
        }) (home.kanshiLayouts or { });
      }
    ) users;

  config.flake.lib.getHostUsers =
    users: usernames:
    let
      allUsers = self.lib.getUsers users;
    in
    builtins.listToAttrs (
      map (username: {
        name = username;
        value = allUsers.${username};
      }) usernames
    );

  options.flake = {
    lib = {
      getUsers = lib.mkOption { type = lib.types.raw; };
      getHostUsers = lib.mkOption { type = lib.types.raw; };
    };

    modules = {
      features = lib.mkOption {
        type = lib.types.lazyAttrsOf lib.types.raw;
        default = { };
      };

      profiles = lib.mkOption {
        type = lib.types.lazyAttrsOf lib.types.raw;
        default = { };
      };

      hosts = lib.mkOption {
        type = lib.types.lazyAttrsOf lib.types.raw;
        default = { };
      };

      users = lib.mkOption {
        type = lib.types.lazyAttrsOf (
          lib.types.submodule {
            options = {
              profiles = lib.mkOption {
                type = lib.types.lazyAttrsOf lib.types.raw;
                default = { };
              };

              home = lib.mkOption {
                type = lib.types.submodule {
                  freeformType = lib.types.lazyAttrsOf lib.types.raw;
                  options.kanshiLayouts = lib.mkOption {
                    type = lib.types.lazyAttrsOf lib.types.raw;
                    default = { };
                  };
                };
                default = { };
              };
            };
          }
        );
        default = { };
      };
    };
  };
}
