{ config, lib, pkgs, ... }:
let

in {
  services.paperless = {
    enable = true;
    dataDir = "/data/Paperless";
    extraConfig = {
      PAPERLESS_OCR_LANGUAGE = "deu+eng";
    };
  };
}
