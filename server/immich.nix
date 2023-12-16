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

      cmd = [ "./start-server.sh" ];

      ports = [
        "2283:3001"
      ];

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
      ];

      cmd = [ "./start-microservices.sh" ];

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
      image = "redis:6.2-alpine@sha256:70a7a5b641117670beae0d80658430853896b5ef269ccf00d1827427e3263fa3";

      extraOptions = [ "--network=immich-bridge" ];
    };

    immich_postgres = {
      image = "tensorchord/pgvecto-rs:pg14-v0.1.11";

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
  
    
