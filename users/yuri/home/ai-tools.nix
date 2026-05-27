{ self, ... }:
{
  flake.modules.users.yuri.home.ai-tools = _: {
    imports = with self.modules.users.yuri.home; [
      # Vibe
      opencode
      oac-models
      git-commit-helpers
    ];
  };
}
