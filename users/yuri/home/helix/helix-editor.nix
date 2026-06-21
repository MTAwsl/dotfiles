_: {
  flake.modules.users.yuri.home.helix-editor = _: {
    programs.helix.settings = {
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
        # replace file explorer with nnn
        e = ":open %sh{hx-nnn-picker '%{buffer_name}'}";
      };
    };
  };
}
