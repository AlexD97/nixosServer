{congig, ...}: {
  services.dunst.settings = {
    global = {
      follow = "mouse";
    };
    logger = {
      summary = "*";
      script = "/home/alexander/.config/eww/Control-Center/scripts/logger.zsh";
    };
  };
  xdg.configFile."eww/scripts/logger.py".source = ./logger.py;
  xdg.configFile."eww/scripts/cache.py".source = ./cache.py;
  xdg.configFile."eww/scripts/utils.py".source = ./utils.py;
  xdg.configFile."eww/scripts/handlers.py".source = ./handlers.py;
  xdg.configFile."eww/notifications/eww.scss".source = ./eww.scss;
  xdg.configFile."eww/notifications/eww.yuck".source = ./eww.yuck;
  xdg.configFile."eww/eww.scss".source = ./global_eww.scss;
  xdg.configFile."eww/eww.yuck".source = ./global_eww.yuck;
}
