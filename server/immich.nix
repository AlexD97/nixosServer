{pkgs, ... }:
let
  dbHostname = "immich_postgres"; 
  dbUsername = "postgres";
  dbPassword = "postgres";
  dbDatabaseName = "immich";

  redisHostname = "192.168.178.24";
  redisPassword = "hunter2";
  photosLocation = "/sharedfolders/Immich";

  immichWebUrl = "http://immich_web:3000";
  immichServerUrl = "http://immich_server:3001";
  immichMachineLearningUrl = "http://immich_machine_learning:3003";

  typesenseApiKey = "abcxyz123";
  typesenseDataDir = "/data";
  
  environment = {
    DB_HOSTNAME = dbHostname;
    DB_USERNAME = dbUsername;
    DB_PASSWORD = dbPassword;
    DB_DATABASE_NAME = dbDatabaseName;

    REDIS_HOSTNAME = "immich_redis";
#    REDIS_PASSWORD = redisPassword;
    
    UPLOAD_LOCATION = photosLocation;

    TYPESENSE_API_KEY = typesenseApiKey;
    TYPESENSE_DATA_DIR = typesenseDataDir;

    IMMICH_WEB_URL = immichWebUrl;
    IMMICH_SERVER_URL = immichServerUrl;
    IMMICH_MACHINE_LEARNING_URL = immichMachineLearningUrl;

    POSTGRES_PASSWORD = dbPassword;
    POSTGRES_USER = dbUsername;
    POSTGRES_DB = dbDatabaseName;

  };
  
in {
  virtualisation.oci-containers.containers = {
    immich_server = {
      image = "ghcr.io/immich-app/immich-server:release";
      volumes = [
        "/sharedfolders/Immich:/usr/src/app/upload"
      ];

      dependsOn = [
        "immich_redis"
        "immich_postgres"
        "typesense"
      ];

      cmd = [ "./start-server.sh" ];

      extraOptions = [ "--network=immich-bridge" ];
      environment = environment;
    };

    immich_microservices = {
      image = "ghcr.io/immich-app/immich-server:release";
      volumes = [
        "/sharedfolders/Immich:/usr/src/app/upload"
      ];
      dependsOn = [
        "immich_redis"
        "immich_postgres"
        "typesense"
      ];

      cmd = [ "./start-microservices.sh" ];

      extraOptions = [ "--network=immich-bridge" ];
      environment = environment;
    };

    immich_web = {
      image = "ghcr.io/immich-app/immich-web:release";

      extraOptions = [ "--network=immich-bridge" ];
      environment = environment;
    };

    typesense = {
      image = "typesense/typesense:0.24.1@sha256:9bcff2b829f12074426ca044b56160ca9d777a0c488303469143dd9f8259d4dd";
      volumes = [
        "tsdata:/data"
      ];

      extraOptions = [ "--network=immich-bridge" ];
      environment = environment;
    };

    immich_redis = {
      image = "redis:6.2-alpine@sha256:70a7a5b641117670beae0d80658430853896b5ef269ccf00d1827427e3263fa3";

      extraOptions = [ "--network=immich-bridge" ];
    };

    immich_postgres = {
      image = "postgres:14-alpine@sha256:28407a9961e76f2d285dc6991e8e48893503cc3836a4755bbc2d40bcc272a441";

      volumes = [
        "pgdata:/var/lib/postgresql/data"
      ];

      extraOptions = [ "--network=immich-bridge" ];
      environment = environment;
    };

    immich_proxy = {
      image = "ghcr.io/immich-app/immich-proxy:release";

      ports = [
        "2283:8080"
      ];

      environment = environment;

      dependsOn = [
        "immich_server"
        "immich_web"
      ];

      extraOptions = [ "--network=immich-bridge" ];
    };
  };
  
  systemd.services.init-immich-network = {
    description = "Create the network bridge for immich.";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "oneshot";
    script = ''
      # Put a true at the end to prevent getting non-zero return code, which will
      # crash the whole service.
      check=$(${pkgs.docker}/bin/docker network ls | grep "immich-bridge" || true)
      if [ -z "$check" ];
        then ${pkgs.docker}/bin/docker network create immich-bridge
        else echo "immich-bridge already exists in docker"
      fi
      ''; 
  };
}
  
    
