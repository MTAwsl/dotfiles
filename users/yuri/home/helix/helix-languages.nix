{ self, ... }:
{
  flake.modules.homeManager.yuri-helix-languages =
    {
      pkgs,
      lib,
      ...
    }:
    {
      programs.helix.languages = {

        # Brillant. Thanks Chino.
        language =
          let
            cfg = {
              nix = {
                auto-format = true;
                formatter.command = "${lib.getExe pkgs.nixfmt}";
              };
              typst = {
                auto-format = true;
              };
              astro = {
                scope = "source.astro";
                injection-regex = "astro";
                file-types = [ "astro" ];
                language-servers = [ "astro-ls" ];
                formatter = {
                  command = "prettier";
                  args = [
                    "--plugin"
                    "prettier-plugin-astro"
                    "--parser"
                    "astro"
                  ];
                };
                auto-format = true;
              };
              python = {
                roots = [
                  "pyproject.toml"
                  "setup.py"
                  "poetry.lock"
                  ".git"
                  ".jj"
                  ".venv/"
                ];
                file-types = [
                  "py"
                  "ipynb"
                ];
                formatter = {
                  command = "ruff";
                  args = [
                    "format"
                    "-"
                  ];
                };
                auto-format = true;
              };
            };

            default-language-servers =
              let
                upstreamLanguages = builtins.tryEval (
                  (builtins.fromTOML (builtins.readFile "${pkgs.helix-unwrapped.src}/languages.toml")).language
                );
              in
              if upstreamLanguages.success then
                upstreamLanguages.value
                |> builtins.filter (
                  l:
                  builtins.hasAttr "name" l
                  && builtins.hasAttr "scope" l
                  && builtins.hasAttr "language-servers" l
                  && l.name != "python"
                )
                |> map (l: lib.nameValuePair l.name { language-servers = _: l.language-servers; })
                |> builtins.listToAttrs
              else
                { };

            codebook-langs = [
              # "c"
              # "cpp"
              # "css"
              "html"
              "markdown"
              "typst"
              # "javascript"
              # "lua"
              # "nix"
              # "python"
              # "rust"
              # "toml"
              # "typescript"
              # "zig"
            ];

            harper-langs = [
              "markdown"
              "typst"
            ];

            append-ls =
              server: langs:
              langs
              |> map (l: lib.nameValuePair l { language-servers.__append = [ server ]; })
              |> builtins.listToAttrs;
          in
          self.lib.infuse cfg [
            default-language-servers
            (append-ls "codebook" codebook-langs)
            (append-ls "harper-ls" harper-langs)
            (append-ls "pyright" [ "python" ])
            (append-ls "ruff" [ "python" ])
          ]
          |> lib.mapAttrsToList (name: value: value // { inherit name; });

        language-server = {
          typescript-language-server = {
            command = "${pkgs.typescript-language-server}/bin/typescript-language-server";
            args = [
              "--stdio"
              "--tsserver-path=${pkgs.typescript}/lib/node_modules/typescript/lib"
            ];
            config.documentFormatting = false;
          };

          pyright = {
            command = "${pkgs.pyright}/bin/pyright-langserver";
            args = [ "--stdio" ];
          };

          ruff = {
            command = "ruff";
            args = [ "server" ];
            environment = {
              "RUFF_TRACE" = "messages";
            };
            config = {
              settings = {
                lineLength = 88;
                # Too lazy to fix ruff linting rule.
                # TODO: Start a template pyproject with uv and nix shell.
                # logLevel = "debug";
                lint = {
                  select = [
                    "E"
                    "F"
                    "W"
                    "B"
                    "I"
                    "UP"
                    "S"
                  ];
                  preview = true;
                };
                format = {
                  preview = true;
                  "quote-style" = "double";
                  "docstring-code-format" = true;
                  "indent-style" = "space";
                };
              };
            };
          };

          tinymist.config = {
            formatterMode = "typstyle";
            formatterProseWrap = true;
          };

          rust-analyzer.config = {
            check.command = "clippy";
          };

          codebook = {
            command = "codebook-lsp";
            args = [ "serve" ];
          };

          harper-ls = {
            command = "harper-ls";
            args = [ "--stdio" ];
          };

          astro-ls = {
            command = lib.getExe pkgs.astro-language-server;
            args = [ "--stdio" ];
            config = {
              typescript = {
                tsdk = "${pkgs.typescript}/lib/node_modules/typescript/lib";
              };
            };
          };
        };
      };
    };
}
