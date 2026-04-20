{ self, ... }:
{
  flake.modules.homeManager.yuri-helix =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      imports = [
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
        }
      ];

      programs.helix = {
        enable = true;
        settings = {
          # theme = "monokai"; # Managed by stylix
          editor = {
            cursorline = true;
            true-color = true;
            color-modes = true;
            bufferline = "multiple";
            line-number = "relative";
            rulers = [
              89
              120
            ];
            indent-guides.render = true;
            soft-wrap = {
              enable = true;
              max-wrap = 25;
              max-indent-retain = 0;
              wrap-indicator = "";
            };

            end-of-line-diagnostics = "warning";
            inline-diagnostics.cursor-line = "warning";
          };

          keys.normal = {
            esc = [
              "collapse_selection"
              "keep_primary_selection"
            ];
          };

          # hmmmm.....u sure?
          keys.normal.space = {
            # replace file explorer with yazi
            e =
              let
                yazi-wrapper = pkgs.writeShellScript "yazi-wrapper" ''
                  if [[ -n $ZELLIJ ]]; then
                    YAZI_TMP=$(mktemp -d)

                    mkfifo "$YAZI_TMP/fifo"

                    zellij run -fc --width 90% --height 90% -x 5% -y 5% -- \
                      sh -c "${pkgs.yazi}/bin/yazi \"$1\" --chooser-file=\"$YAZI_TMP/out\" | tee \"$YAZI_TMP/fifo\"" > /dev/null

                    cat < "$YAZI_TMP/fifo" > /dev/null

                    cat "$YAZI_TMP/out"
                    rm -rf "$YAZI_TMP"
                  else
                    # use the system stty if possible to fix permission issue
                    # on macos
                    STTY=stty
                    if [ -f /bin/stty ]; then
                      STTY=/bin/stty
                    fi

                    # save and restore tty settings
                    # the "official" version fixes settings by using stuff like
                    # `x1b[?1049h]`, which is not what helix uses exactly.
                    # this script just save and restores it instead.
                    SAVED_TTY=$($STTY -g < /dev/tty)
                    $STTY sane < /dev/tty

                    ${pkgs.yazi}/bin/yazi "$1" --chooser-file=/dev/stdout < /dev/tty

                    $STTY "$SAVED_TTY" < /dev/tty
                  fi
                '';
              in
              [
                ":set mouse false"
                ":open %sh{${yazi-wrapper} '%{buffer_name}'}"
                ":redraw"
                ":set mouse true"
              ];
          };
        };

        languages = {

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
                (fromTOML (builtins.readFile "${pkgs.helix-unwrapped.src}/languages.toml")).language
                |> builtins.filter (
                  l:
                  builtins.hasAttr "name" l
                  && builtins.hasAttr "scope" l
                  && builtins.hasAttr "language-servers" l
                  && l.name != "python"
                )
                |> map (l: lib.nameValuePair l.name { language-servers = _: l.language-servers; })
                |> builtins.listToAttrs;

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
    };
}
