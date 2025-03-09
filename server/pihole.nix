{pkgs, ... }:
let
in {
  virtualisation.oci-containers.backend = "docker";
  virtualisation.oci-containers.containers = {
    pihole = {
      autoStart = true;
      image = "pihole/pihole:latest";
      environment = {
        TZ = "Europe/Berlin";
        FTLCONF_dns_upstreams = "1.1.1.1;8.8.8.8";
        FTLCONF_LOCAL_IPV4 = "192.168.178.100";
        FTLCONF_LOCAL_IPV6 = "fd00::52e6:36ff:6496:f0f6";
        FTLCONF_webserver_api_password = "nixpihole";
        # DNS1 = "1.1.1.1";
        # DNS2 = "8.8.8.8";
        # FTLCONF_LOCAL_IPV4 = "192.168.178.100";
        # FTLCONF_LOCAL_IPV6 = "fd00::52e6:36ff:6496:f0f6";
        # WEBPASSWORD = "nixpihole";
      };
      # ports = [
      #   "53:53/tcp"
      #   "53:53/udp"
      #   "67:67/udp"
      #   "80:80/tcp"
      #   "443:443/tcp"
      # ];
      volumes = [
        "/home/alexander/Docker/pihole/etc-pihole:/etc/pihole:rw"
#        "/home/alexander/Docker/pihole/etc-dnsmasq.d:/etc/dnsmasq.d:rw"
      ];
      extraOptions = [
#        "--dns=127.0.0.1"
        "--network=ipvlan_test1"
        "--ip=192.168.178.100"
        "--ip6=fd00::52e6:36ff:6496:f0f6"
#        "--cap-add=NET_ADMIN"
      ];
    };
  };

 system.activationScripts.mkPiholeNetwork = let
  in ''
    check=$(${pkgs.docker}/bin/docker network ls | grep "ipvlan_test1" || true)
    if [ -z "$check" ];
      then
        ${pkgs.docker}/bin/docker network create -d ipvlan \
          --subnet=192.168.178.0/24 \
          --gateway=192.168.178.1 \
          --ipv6 \
          --subnet=fd00::52e6:36ff/64 \
          --gateway=fd00::52e6:36ff:fe3d:123 \
          -o parent=enp1s0 \
          ipvlan_test1
      else echo "immich-bridge already exists in docker"
    fi
  '';
#      --ip-range=192.168.178.150/32 \
  
# sudo podman network create -d ipvlan --subnet=192.168.178.0/24 --gateway=192.168.178.1 --subnet=fd00::52e6:36ff/64 --gateway=fd00::52e6:36ff:fe3d:123 -o parent=wlp4s0 ipvlan_test1
  
  # systemd.services.init-pihole-network = {
  #   description = "Create the network for pihole.";
  #   after = [ "network.target" ];
  #   wantedBy = [ "multi-user.target" ];
  #   serviceConfig.Type = "oneshot";
  #   script = ''
  #     # Put a true at the end to prevent getting non-zero return code, which will
  #     # crash the whole service.
  #     check=$(${pkgs.podman}/bin/podman network ls | grep "macvlan_test2" || true)
  #     if [ -z "$check" ];
  #       then ${pkgs.podman}/bin/podman network create --subnet=192.168.178.0/24 macvlan_test2 
  #       else echo "pihole-network already exists in podman"
  #     fi
  #     ''; 
  # };
}
