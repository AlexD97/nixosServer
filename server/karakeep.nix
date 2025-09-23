{ config, lib, pkgs, ... }:
let

in {
  services.karakeep = {
    enable = true;
    extraEnvironment = {
      DATA_DIR = "/sharedfolders/Karakeep/";
      NEXTAUTH_URL = "karakeep.alexanderdinges.de";
    };
  };
}
