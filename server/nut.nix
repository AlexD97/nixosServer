{ config, lib, pkgs, ... }:
let
  vid = "0463";
  pid = "FFFF";
in {
  power.ups = {
    enable = true;
    mode = "standalone";
    schedulerRules = "/home/alexander/flake/server/nut/nutRules.conf";

    upsmon = {
      enable = true;
      monitor."nutdev1@localhost" = {
        user = "upsmon";
        passwordFile = "/home/alexander/not_in_flake/upsmon_password";
        type = "master";
        powerValue = 1;
      };

      settings = {
        MINSUPPLIES = 1;
        RUN_AS_USER = "root";

        SHUTDOWNCMD = "shutdown -h 0";
        POLLFREQ = 5;
        POLLFREQALERT = 5;
        HOSTSYNC = 15;
        DEADTIME = 15;
        RBWARNTIME = 43200;
        NOCOMMWARNTIME = 300;
        FINALDELAY = 5;

        NOTIFYCMD = "/run/current-system/sw/bin/upssched";

        NOTIFYFLAG = [
          ["ONLINE"       "SYSLOG+WALL+EXEC"]
          ["ONBATT"       "SYSLOG+WALL+EXEC"]
          ["LOWBATT"      "SYSLOG+WALL+EXEC"]
          ["FSD"          "SYSLOG+WALL+EXEC"]
          ["COMMOK"       "SYSLOG+WALL+EXEC"]
          ["COMMBAD"      "SYSLOG+WALL+EXEC"]
          ["SHUTDOWN"     "SYSLOG+WALL+EXEC"]
          ["REPLBATT"     "SYSLOG+WALL+EXEC"]
          ["NOCOMM"       "SYSLOG+WALL+EXEC"]
          ["NOPARENT"     "SYSLOG+WALL+EXEC"]
        ];
      };
    };

    ups."nutdev1" = {
      driver = "usbhid-ups";
      port = "auto";
      description = "Eaton 3S 700 UPS";
      directives = [
        "vendorid = ${vid}"
        "productid = ${pid}"
        "override.battery.charge.low = 50"
#        "ignorelb" # needed to make battery.charge.low relevant for low battery event
      ];
      maxStartDelay = null;
    };

    upsd = {
      enable = true;
      extraConfig = ''
        ALLOW_NO_DEVICE true
      '';
    };

    users = {
      upsmon = {
        passwordFile = "/home/alexander/not_in_flake/upsmon_password";
        upsmon = "primary";
      };
    };
  };

  users = {
    users.nut = {
      isSystemUser = true;
      group = "nut";
      # it does not seem to do anything with this directory
      # but something errored without it, so whatever
      home = "/var/lib/nut";
      createHome = true;
    };
    groups.nut = { };
  };

  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTRS{idVendor}=="${vid}", ATTRS{idProduct}=="${pid}", MODE="664", GROUP="nut", OWNER="nut"
  '';

  systemd.services.upsd.serviceConfig = {
    User = "root";
    Group = "nut";
  };

  systemd.services.upsdrv.serviceConfig = {
    User = "root";
    Group = "nut";
  };

  systemd.services.upsdrv.serviceConfig = {
    Restart = lib.mkOverride 0 "on-failure";
    RestartSec = "3";
  };

  # environment.etc = {
    # all this file needs to do is exist
    # upsdConf = {
    #   text = ''
    #     ALLOW_NO_DEVICE true
    #   '';
    #   target = "nut/upsd.conf";
    #   mode = "0440";
    #   group = "nut";
    #   user = "root";
    # };

    # upsdUsers = {
    #   # update upsmonConf MONITOR to match
    #   text = ''
    #   [upsmon]
    #     password = ${password}
    #     upsmon master
    #   '';
    #   target = "nut/upsd.users";
    #   mode = "0440";
    #   group = "nut";
    #   user = "root";
    # };
    
    # upsmonConf = {
    #   target = "nut/upsmon.conf";
    #   text = ''
    #     RUN_AS_USER root
    #     MONITOR nutdev1@localhost 1 upsmon ${password} master

    #     MINSUPPLIES 1
    #     SHUTDOWNCMD "shutdown -h 0"
    #     POLLFREQ 5
    #     POLLFREQALERT 5
    #     HOSTSYNC 15
    #     DEADTIME 15
    #     RBWARNTIME 43200
    #     NOCOMMWARNTIME 300
    #     FINALDELAY 5

    #     NOTIFYCMD /run/current-system/sw/bin/upssched

    #     NOTIFYFLAG ONLINE       SYSLOG+WALL+EXEC
    #     NOTIFYFLAG ONBATT       SYSLOG+WALL+EXEC
    #     NOTIFYFLAG LOWBATT      SYSLOG+WALL+EXEC
    #     NOTIFYFLAG FSD          SYSLOG+WALL+EXEC
    #     NOTIFYFLAG COMMOK       SYSLOG+WALL+EXEC
    #     NOTIFYFLAG COMMBAD      SYSLOG+WALL+EXEC
    #     NOTIFYFLAG SHUTDOWN     SYSLOG+WALL+EXEC
    #     NOTIFYFLAG REPLBATT     SYSLOG+WALL+EXEC
    #     NOTIFYFLAG NOCOMM       SYSLOG+WALL+EXEC
    #     NOTIFYFLAG NOPARENT     SYSLOG+WALL+EXEC
    #   '';
    #   mode = "0444";
    #   group = "nut";
    #   user = "root";
    # };

    # upsschedConf = {
    #   target = "nut/upssched.conf";
    #   text = ''
    #     CMDSCRIPT /home/alexander/Downloads/upsscript.sh
    #     PIPEFN /home/alexander/Downloads/upssched.pipe
    #     LOCKFN /home/alexander/Downloads/upssched.lock
    #     AT ONBATT * START-TIMER onbatt 10
    #     AT ONLINE * CANCEL-TIMER onbatt
    #     AT LOWBATT * EXECUTE battleer
    #   '';
    #   mode = "0444";
    #   group = "nut";
    #   user = "root";
    # };

    # upsschedScript = {
    #   target = "nut/upssched/upsscript.sh";
    #   text = ''
    #     #!/run/current-system/sw/bin/sh
    #     case $1 in
    #       onbatt)
    #         logger -t upssched "Shutdown"
    #         shutdown -h +0
    #         ;;
    #       battleer)
    #         upssched fsd;;
    #       *)
    #         logger -t upssched "Falscher Parameter";;
    #     esac
    #   '';
    #   mode = "0766";
    #   group = "nut";
    #   user = "root";
    # };
  # };
}

