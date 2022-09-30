{ config, ...}:
{
  xdg.configFile."eww/eww.yuck".source = ./eww.yuck;
  xdg.configFile."eww/eww.scss".source = ./eww.scss;
  xdg.configFile."eww/Control-Center".recursive = ./Control-Center;
};
