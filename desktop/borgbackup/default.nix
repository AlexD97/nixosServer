{pkgs, lib, config, ...} : {
  config.services.borgbackup.jobs =
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
        homePath = "/home/alexander";
        backupPath = "/sharedfolders";
  in {
    homeBackup = rec {
      paths = "${backupPath}";
      encryption = {
        mode = "repokey";
        passCommand = "cat /home/alexander/not_in_flake/backup_passphrase";
      };
      environment.BORG_RSH = "ssh -o 'StrictHostKeyChecking=no' -i ${homePath}/.ssh/id_hetzner_storage_box";
      environment.BORG_UNKNOWN_UNENCRYPTED_REPO_ACCESS_IS_OK = "yes";
      repo = "ssh://u368150@u368150.your-storagebox.de/nixosserverBackup";
      compression = "zlib,6";
      exclude = map (x: paths + "/" + x) common-excludes;
      startAt = "*-*-* 00:03:00";
      extraCreateArgs = "--verbose --stats";
    };
  };
  config.systemd.services = {
    notify-borgbackup-failure = {
      enable = true;
      serviceConfig.User = "alexander";
      environment = {
        DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/1000/bus";
      };
      script = ''
        curl -H "Priority: urgent" -H "Title: Borgbackup failed!" -d "Check logs" https://ntfy.alexanderdinges.de
      '';
    };
    notify-borgbackup-success = {
      enable = true;
      serviceConfig.User = "alexander";
      environment = {
        DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/1000/bus";
      };
      script = ''
        curl -d "Borgbackup successful" https://ntfy.alexanderdinges.de
      '';
    };
    borgbackup-job-homeBackup = {
      unitConfig.OnFailure = "notify-borgbackup-failure.service";
      unitConfig.OnSuccess = "notify-borgbackup-success.service";
      preStart = lib.mkBefore ''
        # waiting for internet after resume-from-suspend
        until /run/wrappers/bin/ping google.com -c1 -q >/dev/null; do :; done
      '';
      #timerConfig.Persistent = true;
    };
  };
  config.systemd.timers = {
    borgbackup-job-homeBackup.timerConfig.Persistent = lib.mkOverride 0 true;
  };
}
