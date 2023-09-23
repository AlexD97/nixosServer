{ config, lib, pkgs, ... }:

{
  services.nginx = {
    enable = true;

    virtualHosts = {
      "photos.alexanderdinges.de" = {
        forceSSL = true;
        useACMEHost = "alexanderdinges.de";
        locations."/" = {
          proxyPass = "http://127.0.0.1:2283";
          extraConfig = ''
            client_max_body_size 0;
          '';
        };
      };
      "syncthing.alexanderdinges.de" = {
        forceSSL = true;
        useACMEHost = "alexanderdinges.de";
        locations."/".proxyPass = "http://127.0.0.1:8384";
      };
      "documents.alexanderdinges.de" = {
        forceSSL = true;
        useACMEHost = "alexanderdinges.de";
        locations."/".proxyPass = "http://127.0.0.1:28981";
      };
      "ntfy.alexanderdinges.de" = {
        forceSSL = true;
        useACMEHost = "alexanderdinges.de";
        locations."/" = {
          proxyPass = "http://127.0.0.1:11611";
          proxyWebsockets = true;
        };
      };
    };
  };
}
