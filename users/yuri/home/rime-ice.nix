_: {
  flake.modules.users.yuri.home.rime-ice =
    { lib, pkgs, ... }:
    {
      home.activation = {
        writeRimeConfig = lib.hm.dag.entryAfter [ "writeBoundry" ] ''
          TARGET="$HOME/.local/share/fcitx5/rime/default.custom.yaml"

          if [ ! -e "$TARGET" ]; then
            mkdir -p "$(dirname "$TARGET")"
            cat <<EOF > "$TARGET"
          patch:
            __include: rime_ice_suggestion:/

          schema_list:
            - schema: rime_ice
          EOF

          fi'';

        writeRimeData = lib.hm.dag.entryAfter [ "writeBoundry" ] ''
          DEST="$HOME/.local/share/fcitx5/rime"
          SRC="${pkgs.rime-ice}/share/rime-data"

          if [ ! -d "$DEST" ]; then
            mkdir -p "$DEST"
          fi

          ln -sfn "$SRC"/* "$DEST/"
        '';
      };
    };
}
