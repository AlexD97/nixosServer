{ config, lib, pkgs, ... }:
let

in {
  services.paperless = {
    enable = true;
    dataDir = "/sharedfolders/Paperless";
    extraConfig = {
      PAPERLESS_OCR_LANGUAGE = "deu+eng";
    };
  };
}
