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
  immichServerUrl = "http://immich_server:2283";
  immichMachineLearningUrl = "http://immich_machine_learning:3003";
  
  environment = {
    DB_HOSTNAME = dbHostname;
    DB_USERNAME = dbUsername;
    DB_PASSWORD = dbPassword;
    DB_DATABASE_NAME = dbDatabaseName;

    REDIS_HOSTNAME = "immich_redis";
#    REDIS_PASSWORD = redisPassword;
    
    UPLOAD_LOCATION = photosLocation;

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
      ];

      # cmd = [ "./start-server.sh" ];

      ports = [
        "2283:2283"
      ];

      extraOptions = [ "--network=immich-bridge" ];
      environment = environment;
    };

    immich_machine_learning = {
      image = "ghcr.io/immich-app/immich-machine-learning:release";
      volumes = [
        "model-cache:/cache"
      ];

      extraOptions = [ "--network=immich-bridge" ];
      environment = environment;
    };

    immich_redis = {
      image = "redis:6.2-alpine@sha256:51d6c56749a4243096327e3fb964a48ed92254357108449cb6e23999c37773c5";

      extraOptions = [ "--network=immich-bridge" ];
    };

    immich_postgres = {
      image = "tensorchord/pgvecto-rs:pg14-v0.2.0@sha256:90724186f0a3517cf6914295b5ab410db9ce23190a2d9d0b9dd6463e3fa298f0";

      volumes = [
        "pgdata:/var/lib/postgresql/data"
      ];

      extraOptions = [ "--network=immich-bridge" ];
      environment = environment;
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
  
    
