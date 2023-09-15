{ config, lib, pkgs, ... }:
let

in {
  services.paperless = {
    enable = true;
    dataDir = "/home/alexander/Dokumente/Paperless/";
    passwordFile = "/home/alexander/Downloads/paperless_password.txt";
    extraConfig = {
      PAPERLESS_OCR_LANGUAGE = "deu+eng";
    };
  };

  systemd.services.paperless-scheduler.after = ["var-lib-paperless.mount"];
  systemd.services.paperless-consumer.after = ["var-lib-paperless.mount"];
  systemd.services.paperless-web.after = ["var-lib-paperless.mount"];
}
