{config, pkgs, ...}:
let
  backup_file_path = "/sharedfolders/Backups/Immich/dump.sql.gz";
in
{
  systemd.timers."backup-immich" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* 02:30:00";
      Persistent = true;
      Unit = "backup-immich.service";
    };
  };

  systemd.services."backup-immich" = {
    script = ''
      ${pkgs.docker}/bin/docker exec -t immich_postgres pg_dumpall -c -U postgres | ${pkgs.gzip}/bin/gzip > ${backup_file_path}
      ${pkgs.curl}/bin/curl -d "Immich backup successful" https://ntfy.alexanderdinges.de/backup-immich
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };
}
