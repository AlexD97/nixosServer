{ config, lib, pkgs, ... }:

{
  services.nginx = {
    enable = true;

    virtualHosts = {
      "photos.alexanderdinges.de" = {
        forceSSL = true;
        useACMEHost = "alexanderdinges.de";
        locations."/".proxyPass = "http://127.0.0.1:2283";
      };
      "syncthing.alexanderdinges.de" = {
        forceSSL = true;
        useACMEHost = "alexanderdinges.de";
        locations."/".proxyPass = "http://127.0.0.1:8384";
      };
    };
  };
}
