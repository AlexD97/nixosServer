{ config, pkgs, ...}:
{
  home.packages = with pkgs; [
    at-spi2-core
    at-spi2-atk
    swaynotificationcenter
  ];
  xdg.configFile."swaync/config.json".source = ./config.json;
  systemd.user.services.swaync = {
    Unit = {
      Description = "SwayNotificationCenter notification daemon";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
      Requisite = [ "graphical-session.target"];
    };
    Service = {
      Type = "dbus";
      BusName = "org.freedesktop.Notifications";
      # We don't pass the path to the nix store configuration file to allow reloading
      # without restarting the service
      ExecStart = "${pkgs.swaynotificationcenter}/bin/swaync";
      ExecReload = "${pkgs.swaynotificationcenter}/bin/swaync-client --reload-config --reload-css";
      Restart = "on-failure";
      RestartSec = "1sec";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
