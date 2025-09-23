# { config, lib, pkgs, ... }:
# let

# in {
#   services.karakeep = {
#     enable = true;
#     browser.enable = false;
#     extraEnvironment = {
# #      DATA_DIR = lib.mkForce "/sharedfolders/Karakeep/";
#       NEXTAUTH_URL = "karakeep.alexanderdinges.de";
#     };
#   };
# }

{pkgs, lib, ... }:
let
in {
  virtualisation.oci-containers.backend = "docker";

  systemd.services.create-karakeep-network = {
    before = [ "oci-container-karakeep.service" ];
    after = [ "docker.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "oneshot";
    script = ''
      ${pkgs.docker}/bin/docker network ls | grep karakeep-net || \
      ${pkgs.docker}/bin/docker network create karakeep-net
    '';
  };
  
  virtualisation.oci-containers.containers = {
    karakeep = {
      autoStart = true;
      image = "ghcr.io/karakeep-app/karakeep:latest";
      environment = {
        KARAKEEP_VERSION = "release";
        NEXTAUTH_SECRET = "super_random_string";
        MEILI_MASTER_KEY = "o9CRGYLzxJ0LhVlrGmwC8D95BfgAsulaAIfb05yRTTM";
        NEXTAUTH_URL = "http://localhost:3000";
        MEILI_ADDR = "http://meilisearch:7700";
        BROWSER_WEB_URL = "http://chrome:9222";
        DATA_DIR = "/data";
      };
      environmentFiles = [
        "/home/alexander/not_in_flake/karakeep.env"
      ];
      volumes = [
        "/sharedfolders/Karakeep:/data"
      ];
      ports = [ "3000:3000" ];
      extraOptions = [
        "--network=karakeep-net"
      ];
      dependsOn = [ "meilisearch" "chrome" ];
    };
    chrome = {
      image = "gcr.io/zenika-hub/alpine-chrome:124";
      cmd = [
        "--no-sandbox"
        "--disable-gpu"
        "--disable-dev-shm-usage"
        "--remote-debugging-address=0.0.0.0"
        "--remote-debugging-port=9222"
        "--hide-scrollbars"
      ];
      ports = [ "9222:9222" ];
      extraOptions = [
        "--network=karakeep-net"
      ];
    };
    meilisearch = {
      image = "getmeili/meilisearch:v1.13.3";
      environment = {
        MEILI_NO_ANALYTICS = "true";
        MEILI_MASTER_KEY = "o9CRGYLzxJ0LhVlrGmwC8D95BfgAsulaAIfb05yRTTM";
      };
      volumes = [ "meilisearch:/meili_data" ];
      ports = [ "7700:7700" ];
      extraOptions = [
        "--network=karakeep-net"
      ];
    };
  };
}
