input@{ config, pkgs, ... }:
let 
  confFile = builtins.readFile ./config.py;
in
{
  xdg.configFile."newm/config.py".text = confFile;
  xdg.configFile."newm/launcher.py".text = ''
    entries = {
      "firefox": "MOZ_ENABLE_WAYLAND=1 firefox",
      "nautilus": "nautilus",
      "alacritty": "alacritty",
    }

    shortcuts = {
      1: ("Firefox", "MOZ_ENABLE_WAYLAND=1 firefox"),
      2: ("Emacs", "emacs"),
      3: ("Nautilus", "nautilus")
    }
  '';

  xdg.configFile."mako/config".text = ''
    layer=overlay
    background-color=#0D2D2A
    default-timeout=5000
    border-size=0
    border-radius=12
  '';

  xdg.configFile."waybar/config".source = ./waybar/config;
  xdg.configFile."waybar/style.css".source = ./waybar/style.css;
  xdg.configFile."rofi/config.rasi".source = ./rofi.rasi;

  home.packages = with pkgs; [
    newm
    waybar
    wob
    rofi-wayland
    mako
    libnotify

    pywm-fullscreen

    grim
    slurp

    gnome.nautilus

    sway
  ];

  home.file."wallpaper.jpg".source = ./wallpaper.jpg;
}
