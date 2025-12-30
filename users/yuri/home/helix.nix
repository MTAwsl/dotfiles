{ ... }:
{
  flake.modules.homeManager.yuri-helix =
    { pkgs, lib, ... }:
    {
      imports = [
        {
          home.packages = with pkgs; [
            nodejs
            nodePackages.typescript
            astro-language-server
            nixfmt
          ];
        }
      ];

      programs.helix = {
        enable = true;
        settings = {
          theme = "monokai";
          editor = {
            cursorline = true;
            true-color = true;
            soft-wrap = {
              enable = true;
              max-wrap = 25;
              max-indent-retain = 0;
              wrap-indicator = "";
            };
          };
        };

        languages = {
          language = [
            {
              name = "nix";
              auto-format = true;
              formatter.command = lib.getExe pkgs.nixfmt;
            }
            {
              name = "astro";
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
            }
          ];

          language-server = {
            typescript-language-server = {
              command = "${pkgs.nodePackages.typescript-language-server}/bin/typescript-language-server";
              args = [
                "--stdio"
                "--tsserver-path=${pkgs.nodePackages.typescript}/lib/node_modules/typescript/lib"
              ];
              config.documentFormatting = false;
            };

            astro-ls = {
              command = lib.getExe pkgs.astro-language-server;
              args = [ "--stdio" ];
              config = {
                typescript = {
                  tsdk = "${pkgs.nodePackages.typescript}/lib/node_modules/typescript/lib";
                };
              };
            };
          };
        };
      };
    };
}
