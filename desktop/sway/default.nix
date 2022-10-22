{ pkgs, config, ... }:
let
  #modifier = config.wayland.windowManager.sway.config.modifier;
  my_modifier = "Mod4";
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
      "${my_modifier}+Return" = "exec alacritty";
      "${my_modifier}+q" = "kill";


      "${my_modifier}+v" = "split vertical";
      "${my_modifier}+h" = "split horizontal";
      "${my_modifier}+w" = "split toggle";

      "${my_modifier}+Shift+t" = "move right";
      "${my_modifier}+Shift+n" = "move left";
      "${my_modifier}+Shift+r" = "move down";
      "${my_modifier}+Shift+g" = "move up";
    };

    terminal = "${pkgs.alacritty}";
    menu = "${pkgs.rofi} -show run";

    output = {
      eDP-1 = {
        scale = "1.0";
      };
    };

    input = {
      "type:keyboard" = {
        xkb_model = "pc105";
        xkb_layout =  "de";
        xkb_variant = "neo";
      };
      "type:touchpad" = {
        tap = "enabled";
        natural_scroll = "enabled";
      };
    };
  };
}
