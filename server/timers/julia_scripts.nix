{config, pkgs, ...}:
{
  systemd.timers."julia-org-carry-over" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* 02:00:00";
      Persistent = true;
      Unit = "julia-org-carry-over.service";
    };
  };

  systemd.services."julia-org-carry-over" = {
    script = ''
      ${pkgs.julia} ~/flake/scripts/julia_scripts/scripts/carryoverScript.jl
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "alexander";
    };
  };

  systemd.services."julia-org-extract" = {
    script = ''
      ${pkgs.julia} ~/flake/scripts/julia_scripts/scripts/extractScript.jl
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "alexander";
      After = [ "multi-user.target" ];
      Requires = [ "multi-user.target" ];
    };
}
