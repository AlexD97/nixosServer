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
      ${pkgs.julia-bin}/bin/julia /home/alexander/flake/scripts/julia_scripts/scripts/carryoverScript.jl
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "alexander";
    };
  };

  systemd.services."julia-org-extract" = {
    # script = ''
    #   ${pkgs.julia-bin}/bin/julia ~/flake/scripts/julia_scripts/scripts/extractScript.jl
    # '';
    wantedBy = [ "multi-user.target" ];
    after = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      User = "alexander";
      ExecStart = "${pkgs.julia-bin}/bin/julia /home/alexander/flake/scripts/julia_scripts/scripts/extractScript.jl";
    };
  };
}
