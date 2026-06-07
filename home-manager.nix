{
  inputs,
  self,
  withSystem,
  ...
}:
{
  flake.homeConfigurations =
    let
      mkHmConfig =
        system: isFull:
        withSystem system (
          {
            system,
            pkgs,
            lib,
            ...
          }:
          let
            users = self.lib.getHostUsers self.modules.users [ "yuri" ];
            inherit (users) yuri;
          in
          inputs.home-manager.lib.homeManagerConfiguration (rec {
            inherit pkgs;
            extraSpecialArgs = {
              # FIX: Remove after all conditions in overlays/yazi-plugins.nix are satisfied.
              inherit (pkgs) yaziPluginsHomeModule;
            };
            modules = [
              self.modules.features.nix-hm
            ]
            # Import user profiles.
            ++ lib.optional (!isFull) (
              with yuri.profiles;
              [
                hm-cli-workflow
              ]
            )
            ++ lib.optional isFull (
              with yuri.profiles;
              [
                hm-cli-workflow-full
              ]
            );
          })
        );
    in
    {
      "yuri@x86" = (mkHmConfig "x86_64-linux" true);
      "yuri@arm" = (mkHmConfig "aarch64-linux" true);
      "yuri@x86-min" = (mkHmConfig "x86_64-linux" false);
      "yuri@arm-min" = (mkHmConfig "aarch64-linux" false);
    };
}
