{congig, ...}: {
  services.dunst.settings = {
    global = {
      follow = "mouse";
    };
    logger = {
      summary = "*";
      script = "/home/alexander/.config/eww/scripts/logger.py";
    };
  };
  xdg.configFile."eww/scripts/logger.py".source = ./logger.py;
  xdg.configFile."eww/notifications/eww.scss".source = ./eww.scss;
  xdg.configFile."eww/notifications/eww.yuck".source = ./eww.yuck;
}
