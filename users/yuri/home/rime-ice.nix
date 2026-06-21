_: {
  flake.modules.users.yuri.home.rime-ice =
    { lib, pkgs, ... }:
    {
      home.activation = {
        writeRimeConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
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

        writeRimeData = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          DEST="$HOME/.local/share/fcitx5/rime"
          SRC="${pkgs.rime-ice}/share/rime-data"

          if [ ! -d "$DEST" ]; then
            mkdir -p "$DEST"
          fi

          for source_path in "$SRC"/*; do
            name="$(basename -- "$source_path")"

            if [ "$name" = "build" ]; then
              continue
            fi

            target_path="$DEST/$name"

            if [ -L "$target_path" ] || [ -f "$target_path" ]; then
              rm -f -- "$target_path"
            fi

            if [ ! -e "$target_path" ]; then
              ln -s -- "$source_path" "$target_path"
            fi
          done
        '';
      };
    };
}
