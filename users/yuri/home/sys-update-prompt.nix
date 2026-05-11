{ ... }:
{
  flake.modules.homeManager.yuri-sys-update-prompt =
    {
      config,
      options,
      pkgs,
      lib,
      ...
    }:
    let
      flakePath = "${config.home.homeDirectory}/.config/nix-config";
      hasNiri = lib.hasAttrByPath [ "programs" "niri" ] options;
      checkFlakeScript = pkgs.writeShellScriptBin "check-flake-age" ''
        if [ ! -f "${flakePath}/flake.lock" ]; then
            exit 0
        fi

        LAST_UPDATE=$(${pkgs.jq}/bin/jq '[.nodes[].locked.lastModified | select(. != null)] | max' -r "${flakePath}/flake.lock")
        CURRENT_TIME=$(date +%s)
        MONTH_SECONDS=$((30 * 24 * 60 * 60))

        if [ $((CURRENT_TIME - LAST_UPDATE)) -gt $MONTH_SECONDS ]; then
            DAYS_AGO=$(( (CURRENT_TIME - LAST_UPDATE) / 86400 ))
            
            if [ "$1" == "--notify" ]; then
                ${pkgs.libnotify}/bin/notify-send -u critical \
                  "NixOS Update Reminder" \
                  "Your flake.lock is $DAYS_AGO days old. Consider running 'nix flake update'."
            else
                echo -e "\e[1;33m[!] Warning: Your flake.lock hasn't been updated in $DAYS_AGO days.\e[0m"
            fi
        fi
      '';
    in
    {
      config = lib.mkMerge (
        [
          {
            home.packages =
              with pkgs;
              [
                checkFlakeScript
                jq
              ]
              ++ lib.optionals config.home.isDesktopProfile [
                libnotify
              ];

            programs.zsh.initContent = ''
              ${checkFlakeScript}/bin/check-flake-age
            '';
          }
        ]
        ++ lib.optionals hasNiri [
          (lib.mkIf config.home.isDesktopProfile {
            programs.niri.settings.spawn-at-startup = [
              {
                command = [
                  "${checkFlakeScript}/bin/check-flake-age"
                  "--notify"
                ];
              }
            ];
          })
        ]
      );
    };
}
