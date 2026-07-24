{ config, pkgs, lib, ... }:
let
  allDevicesExceptPixel = {
    phone = {
      name = "phone";
      id = "A2KIQS2-TFUCGOR-OM7RYUB-FRPLNDV-GB2S37W-7Z6PAST-UYSPLUB-ORV5SA4";
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
