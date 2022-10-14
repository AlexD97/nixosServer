{ pkgs, config, ... }:

{
  wayland.windowManager.sway.enable = true;
  wayland.windowManager.sway.config = {
    # navigation keys
    up = "g";
    down = "r";
    left = "n";
    right = "t";

    terminal = "${pkgs.alacritty}";
    menu = "${pkgs.rofi} -show run";
  };
}
