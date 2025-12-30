{ ... }:
{
  flake.modules.nixos.user-yuri = { pkgs, lib, ... }: {
    users.users.yuri = {
      initialHashedPassword = "$2b$05$E6jMmkL6CzIotAr33rISt.TCmfPeexxU6iRM7zXtzmh6Cwfyrq17W";
      isNormalUser = true;
      description = "Sayuri Nekomiya";
      extraGroups = [ "networkmanager" "wheel" ];
    };

    home-manager.users.yuri = {
      home = {
        username = "yuri";
        homeDirectory = "/home/yuri";
        stateVersion = "25.11";
        packages = with pkgs; [
          nodejs
          nodePackages."typescript"
          astro-language-server
        ];
      };

      programs = {
        home-manager.enable = true;

        git = {
          enable = true;
          userName = "Sayuri Nekomiya";
          userEmail = "bbh@awsl.rip";
          extraConfig = {
            init.defaultBranch = "master";
          };
        };

        yazi = {
          enable = true;
          enableBashIntegration = true;
          enableZshIntegration = true;
          plugins = with pkgs.yaziPlugins; {
            inherit chmod smart-enter vcs-files git full-border;
          };
        };

        helix = {
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
                formatter.command = lib.getExe pkgs.nixfmt-rfc-style;
              }
              {
                name = "astro";
                scope = "source.astro";
                injection-regex = "astro";
                file-types = ["astro"];
                language-servers = ["astro-ls"];
                formatter = {
                  command = "prettier";
                  args = ["--plugin" "prettier-plugin-astro" "--parser" "astro"];
                };
                auto-format = true;
              }
            ];

            language-server = {
              typescript-language-server = {
                command = "${pkgs.nodePackages.typescript-language-server}/bin/typescript-language-server";
                args = [ "--stdio" "--tsserver-path=${pkgs.nodePackages.typescript}/lib/node_modules/typescript/lib" ];
                config.documentFormatting = false;
              };

              astro-ls = {
                command = lib.getExe pkgs.astro-language-server;
                args = ["--stdio"];
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
    };
  };
}

