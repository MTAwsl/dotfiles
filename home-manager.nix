{ inputs, self, withSystem, ... }: {
  flake.homeConfigurations = 
    let
      mkHmConfig = system: withSystem system (
        { system, pkgs, ... }:
        let
          users = self.lib.getHostUsers self.modules.users [ "yuri" ];
          inherit (users) yuri;
        in
        inputs.home-manager.lib.homeManagerConfiguration (
          rec {
            inherit pkgs;
            extraSpecialArgs = {
              # FIX: Remove after all conditions in overlays/yazi-plugins.nix are satisfied.
              inherit (pkgs) yaziPluginsHomeModule;
            };
            modules = [
              self.modules.features.nix-hm
            ]
            # Import user profiles.
            ++ (with yuri.profiles; [
              hm-cli-workflow
            ]);
          })
      );
    in
    {
      "yuri@x86" = (mkHmConfig "x86_64-linux");
      "yuri@arm" = (mkHmConfig "aarch64-linux");
    };
}
