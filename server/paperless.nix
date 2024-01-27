{ config, lib, pkgs, ... }:
let

in {
  services.paperless = {
    enable = true;
    dataDir = "/sharedfolders/Paperless";
    settings = {
      PAPERLESS_URL = "https://documents.alexanderdinges.de";
      PAPERLESS_OCR_LANGUAGE = "deu+eng";
    };
  };
}
