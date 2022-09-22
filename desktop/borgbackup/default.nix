{pkgs, lib, config, ...} : {
  services.borgbackup.jobs =
    let common-excludes = [
          # Largest cache dirs
          ".cache"
          "*/cache2" # firefox
          "*/Cache"
          "*/.cache"
          "*/cache"
          ".gradle"
          ".cmake"
          ".crashlytics"
          ".java"
          ".julia"
          ".jupyter"
          ".mathlib"
          ".vpython_cipd_cache"
          ".vpython_root"
          ".zoom"
          ".config/kwinrc.lock"
          ".local/share/baloo"
          ".config/Code/CachedData"
          ".container-diff"
          ".npm/_cacache"
          # Work related dirs
          "*/node_modules"
          "*/bower_components"
          "*/_build"
          "*/.tox"
          "*/venv"
          "*/.venv"
        ];
  in {
    homeBackup = {
      paths = "${config.home.homeDirectory}";
      encryption.mode = "none";
      environment.BORG_RSH = "ssh -i ${config.home.homeDirectory}/.ssh/id_rsa";
      repo = "ssh://alexander@omvNAS/sharedfolders/Backups/NixosLaptopBackup";
      exclude = map (x: paths + "/" + x) common-excludes;
      startAt = "*-*-01/2 00:00:00";
      extraCreateArgs = "--verbose --stats";
    };
  };
  config.systemd.services = {
    notify-borgbackup-failure = {
      enable = true;
      serviceConfig.User = "alexander";
      script = ''
        ${pkgs.libnotify}/bin/notify-send -u critical "Borgbackup failed!" "Check logs"
      '';
    };
    borgbackup-job-homeBackup = {
      unitConfig.OnFailure = "notify-borgbackup-failure.service";
      preStart = lib.mkBefore ''
        # waiting for internet after resume-from-suspend
        until /run/wrappers/bin/ping google.com -c1 -q >/dev/null; do :; done
      '';
      timerConfig.Persistent.true;
    };
  };
}
