{ self, ... }:
{
  flake.modules.homeManager.yuri-ai-tools =
    { ... }:
    {
      imports = with self.lib.withPrefix "yuri" self.modules.homeManager; [
        # Vibe
        opencode
        oac-models
        git-commit-helpers
      ];
    };
}
