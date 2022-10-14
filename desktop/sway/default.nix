{ pkgs, config, ... }:
let
  #modifier = config.wayland.windowManager.sway.config.modifier;
  my_modifier = "Control";
in
{
  wayland.windowManager.sway.enable = true;
  wayland.windowManager.sway.config = {
    # navigation keys
    up = "g";
    down = "r";
    left = "n";
    right = "t";

    modifier = my_modifier;
    keybindings = {
      "${my_modifier}+c" = "mode resize";
      "${my_modifier}+d" = "exec rofi -show run &";
    };

    terminal = "${pkgs.alacritty}";
    menu = "${pkgs.rofi} -show run";
  };
}
