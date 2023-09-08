{pkgs, ... }:
let
  # dbHostname = "immich_postgres";
in
virtualisation.oci-containers.containers = {
  pihole = {
    autoStart = true;
    image = "pihole/pihole:latest";
    environment = {
      TZ = "Europe/Berlin";
      DNS1 = "1.1.1.1";
      DNS2 = "8.8.8.8";
    };
    ports = [
      "53:53/tcp"
      "53:53/udp"
      "67:67/udp"
      "80:80/tcp"
      "443:443/tcp"
    ];
    volumes = [
      "/home/alexander/Downloads/docker/etc-pihole:/etc/pihole:rw"
      "/home/alexander/Downloads/docker/etc-dnsmasq.d:/etc/dnsmasq.d:rw"
    ];
    extraOptions = [
      "--network=pihole_macvlan"
    ];
  };
}

system.activationScripts.mkPiholeNetwork = let
  myDocker = config.virtualisation.oci-containers.backend;
  dockerBin = "${pkgs.${myDocker}}/bin/${myDocker}";
in ''
  ${dockerBin} network create -d macvlan \
    --subnet=192.168.178.0/24 \
    --gateway=192.168.178.1 \
    --ip-range=192.168.178.150/32 \
    -o parent=wlp4s0
'';
