{config, pkgs, ...}:
let
  # WARNING: Change the url if healthchecks is changed!
  healthchecks-url = "https://healthchecks.alexanderdinges.de/ping/73201aa8-cb70-4b82-b55e-e6db6eaa1dae";
in
{
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
      /etc/profiles/per-user/alexander/bin/emacs --batch --script /home/alexander/flake/scripts/calendar_init.el
      ${pkgs.curl}/bin/curl ${healthchecks-url}
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "alexander";
      TimeoutStopSec = "300";
    };
  };
}
