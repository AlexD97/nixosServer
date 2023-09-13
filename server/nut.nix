{ config, lib, pkgs, ... }:
let
  vid = "0463";
  pid = "FFFF";
  password = "nichtgeheim";
in {
  power.ups = {
    enable = true;

    ups."eaton" = {
      driver = "usbhid-ups";
      port = "auto";
      description = "Eaton 3S 700 UPS";
      directives = [
        "vendorid = ${vid}"
        "productid = ${pid}"
      ];
      maxStartDelay = null;
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
    User = "nut";
    Group = "nut";
  };

  systemd.services.upsdrv.serviceConfig = {
    User = "nut";
    Group = "nut";
  };

  environment.etc = {
    # all this file needs to do is exist
    upsdConf = {
      text = "";
      target = "nut/upsd.conf";
      mode = "0440";
      group = "nut";
      user = "nut";
    };

    upsdUsers = {
      # update upsmonConf MONITOR to match
      text = ''
      [upsmon]
        password = ${password}
        upsmon master
      '';
      target = "nut/upsd.users";
      mode = "0440";
      group = "nut";
      user = "nut";
    };
    
    upsmonConf = {
      target = "nut/upsmon.conf";
      text = ''
        RUN_AS_USER nut
        MONITOR eaton@localhost 1 upsmon ${password} master

        SHUTDOWNCMD "shutdown -h 0"
        NOTIFYCMD upssched
      '';
      mode = "0444";
    };

    upsschedConf = {
      target = "nut/upssched.conf";
      text = ''
        CMDSCRIPT /etc/nut/upssched/upsscript.sh
        AT ONBATT * START-TIMER onbatt 10
        AT ONLINE * CANCEL-TIMER onbatt
        AT LOWBATT * EXECUTE battleer
      '';
      mode = "0444";
    };

    upsschedScript = {
      target = "nut/upssched/upsscript.sh";
      text = ''
        #!/run/current-system/sw/bin/sh
        case $1 in
          onbatt)
            /sbin/shutdown -h +0;;
          battleer)
            /sbin/upssched fsd;;
          *)
            echo "Falscher Parameter";;
        esac
      '';
      mode = "0544";
    };
  };
};
