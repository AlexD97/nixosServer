{ config, pkgs, lib, ... }:
let
  allDevicesExceptPixel = {
    desktop = {
      name = "desktop";
      id = " S6NVNGZ-6S56NOX-RM3YCQP-PAKJN3J-BJHQ3VE-FRAA6BC-XPYBXUM-T5WEBAO";
    };
    phone = {
      name = "phone";
      id = "R3X7TBQ-HG35NDY-OXJSFNG-MFNWHAV-HUIRI4G-YCKWIT6-4WXYHG2-3QHBIQM";
    };
    tablet = {
      name = "tablet";
      id = "LQBHRI2-RDHW5ZM-PBQ42UZ-6XUC2BV-R6V24ML-UDOJTQB-XN37KDK-4FOJ7QJ";
    };
    laptop = {
      name = "laptop";
      id = "KGFTRCU-37GTOPV-PIDJJ3L-TUCK2YL-HRXXCME-ETPEVP3-5UFFSLK-VG3KAQX";
    };
  };
  allDevices = allDevicesExceptPixel // {
    pixel = {
      name = "pixel";
      id = "SAJDLKJ-3XSNWEG-64OCUL2-KZ4YBTA-OYM25JJ-PI2G7K6-LW4BAIK-ZBBKYA7";
    };
  };
  devicesNamesExceptPixel = [
    "desktop"
    "phone"
    "tablet"
    "laptop"
  ];
  devicesNames = devicesNamesExceptPixel ++ [
    "pixel"
  ];
in
{
  services.syncthing = {
    enable = true;
    guiAddress = "0.0.0.0:8384";
    settings.devices = allDevices;
    dataDir = "/sharedfolders/Syncthing";
    user = "alexander";

    settings.folders =
      let
        staggered = {
          type = "staggered";
          params = {
            cleanInterval = "3600";
            maxAge = "2592000";
          };
        };
      in
        {
        Notizen = {
          path = "/sharedfolders/Syncthing/Dokumente/Notizen";
          versioning = staggered;
          devices = devicesNamesExceptPixel;
          id = "bvl4i-olzll";
        };
        Geistliches = {
          path = "/sharedfolders/Syncthing/Dokumente/Geistliches";
          versioning = staggered;
          devices = devicesNamesExceptPixel;
          id = "64kub-awlpo";
        };
      };
  };
}
