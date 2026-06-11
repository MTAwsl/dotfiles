{
  inputs,
  self,
  withSystem,
  lib,
  ...
}:
{
  flake.homeConfigurations =
    let
      mkHmConfig =
        system: profTypeRaw:
        withSystem system (
          {
            system,
            pkgs,
            ...
          }:
          let
            users = self.lib.getHostUsers self.modules.users [ "yuri" ];
            profType =
              if
                (builtins.elem profTypeRaw [
                  "min"
                  "full"
                  "remote"
                ])
              then
                profTypeRaw
              else
                "min";
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
            ++ lib.optionals (profType == "min") (
              with yuri.profiles;
              [
                hm-cli-workflow
              ]
            )
            ++ lib.optionals (profType == "full") (
              with yuri.profiles;
              [
                hm-cli-workflow-full
              ]
            )
            ++ lib.optionals (profType == "remote") (
              with yuri.profiles;
              [
                hm-cli-workflow-remote
              ]
            );
          })
        );
    in
    {
      "yuri@x86" = (mkHmConfig "x86_64-linux" "full");
      "yuri@arm" = (mkHmConfig "aarch64-linux" "full");
      "yuri@x86-remote" = (mkHmConfig "x86_64-linux" "remote");
      "yuri@arm-remote" = (mkHmConfig "aarch64-linux" "remote");
      "yuri@x86-min" = (mkHmConfig "x86_64-linux" "min");
      "yuri@arm-min" = (mkHmConfig "aarch64-linux" "min");
    };
}
