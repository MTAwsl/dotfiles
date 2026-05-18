_: {
  flake.modules.users.yuri.home.helix-packages =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        nodejs
        typescript
        astro-language-server
        nixfmt
        nixd
        deadnix
        statix

        dockerfile-language-server # Dockerfile
        docker-compose-language-service

        bash-language-server # Bash
        yaml-language-server # YAML

        jq
        jq-lsp

        pyright # Python (Type checker & LSP)
        ruff

        rust-analyzer
        clippy

        cmake-language-server # CMake
        taplo # TOML

        clang-tools # C / C++            gopls # Go
        gotools # Go formatters/tools
        lua-language-server # Lua
        jdt-language-server # Java
        omnisharp-roslyn
        marksman # Markdown
        lldb

        nixd
        tinymist # typst
        typstyle
        vscode-langservers-extracted # html/css/json/eslint
        codebook # spell check
        harper
      ];
    };
}
