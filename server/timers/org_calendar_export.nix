{config, ...}:

systemd.timers."org-calendar-export" = {
  wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "5m";
      OnUnitActiveSec = "15m";
      Unit = "org-calendar-export.service";
    };
};

systemd.services."org-calendar-export" = {
  script = ''
    emacs --batch --script ~/flake/scripts/calendar_init.el
  '';
  serviceConfig = {
    Type = "oneshot";
    User = "alexander";
  };
};

