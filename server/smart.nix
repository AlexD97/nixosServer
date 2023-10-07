{config, ...}:
let

in {
  imports = [ ../custom/modules/smartd.nix ];
  disabledModules = [ "services/monitoring/smartd.nix" ];

  services.smartd = {
    enable = true;
    notifications.ntfy.enable = true;
    notifications.mail.enable = false;
    notifications.wall.enable = true;
    notifications.test = true;
  };
}
