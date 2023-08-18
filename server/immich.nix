{pkgs, ... }:
let
  
  olaf = "hallo";
  
in {
  virtualisation.oci-containers.containers = {
    immich_server = {
      image = "ghcr.io/immich-app/immich-server:release";
      volumes = [
        "/home/alexander/Bilder/Immich:/usr/src/app/upload"
      ];

      dependsOn = [
        "redis"
        "database"
        "typesense"
      ];
    };

    immich_microservices = {
      image = "ghcr.io/immich-app/immich-server:release";
      volumes = [
        "/home/alexander/Bilder/Immich:/usr/src/app/upload"
      ];
      dependsOn = [
        "redis"
        "database"
        "typesense"
      ];
    };

    immich_web = {
      image = ghcr.io/immich-app/immich-web:release;
    };

    immich_typesense = {
      image = "typesense/typesense:0.24.1@sha256:9bcff2b829f12074426ca044b56160ca9d777a0c488303469143dd9f8259d4dd";
      volumes = [
        "tsdata:/data"
      ];

      environment = {
        TYPESENSE_API_KEY = "random-text654321";
        TYPESENSE_DATA_DIR = /data;
      };
    };

    immich_redis = {
      image = "redis:6.2-alpine@sha256:70a7a5b641117670beae0d80658430853896b5ef269ccf00d1827427e3263fa3";
    };

    immich_database = {
      image = "postgres:14-alpine@sha256:28407a9961e76f2d285dc6991e8e48893503cc3836a4755bbc2d40bcc272a441";

      volumes = [
        "pgdata:/var/lib/postgresql/data"
      ];

      environment = {
        POSTGRES_PASSWORD = postgres;
        POSTGRES_USER = postgres;
        POSTGRES_DB = immich;
      };
    };

    immich_proxy = {
      image = "ghcr.io/immich-app/immich-proxy:release";

      ports = [
        "2283:8080"
      ];

      environment = {
        IMMICH_SERVER_URL = "http://immich_server:3001";
        IMMICH_WEB_URL = "http://immich_web:3000";
      };

      dependsOn = [
        "immich_server"
        "immich_web"
      ];
    };
  };
}
  
    
