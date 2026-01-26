{ ... }:
{
  flake.modules.homeManager.yuri-xdg =
    { ... }:
    {
      xdg.mimeApps = {
        enable = true;

        defaultApplications = {
          # Images: Swayimg default
          "image/jpeg" = [ "swayimg.desktop" ];
          "image/png" = [ "swayimg.desktop" ];
          "image/gif" = [ "swayimg.desktop" ];
          "image/webp" = [ "swayimg.desktop" ];
          "image/tiff" = [ "swayimg.desktop" ];
          "image/bmp" = [ "swayimg.desktop" ];
          "image/svg+xml" = [ "swayimg.desktop" ];

          # Videos: VLC default, MPV fallback
          "video/mp4" = [
            "vlc.desktop"
            "mpv.desktop"
          ];
          "video/x-matroska" = [
            "vlc.desktop"
            "mpv.desktop"
          ]; # .mkv
          "video/webm" = [
            "vlc.desktop"
            "mpv.desktop"
          ];
          "video/quicktime" = [
            "vlc.desktop"
            "mpv.desktop"
          ]; # .mov
          "video/x-msvideo" = [
            "vlc.desktop"
            "mpv.desktop"
          ]; # .avi
          "video/mpeg" = [
            "vlc.desktop"
            "mpv.desktop"
          ];
        };
      };
    };
}
