{pkgs, ... }:
let
  # dbHostname = "immich_postgres";
in {
#   virtualisation.oci-containers.containers = {
#     pihole = {
#       autoStart = true;
#       image = "pihole/pihole:latest";
#       environment = {
#         TZ = "Europe/Berlin";
#         DNS1 = "1.1.1.1";
#         DNS2 = "8.8.8.8";
#         ServerIP = "192.168.179.150";
#       };
#       # ports = [
#       #   "53:53/tcp"
#       #   "53:53/udp"
#       #   "67:67/udp"
#       #   "80:80/tcp"
#       #   "443:443/tcp"
#       # ];
#       volumes = [
#         "/home/alexander/Downloads/docker/etc-pihole:/etc/pihole:rw"
#         "/home/alexander/Downloads/docker/etc-dnsmasq.d:/etc/dnsmasq.d:rw"
#       ];
#       extraOptions = [
#         #        "--network=macvlan_test1"
# #        "--dns=127.0.0.1"
#         "--network=macvlan_test2"
#         "--ip=192.168.179.150"
#         "--cap-add=NET_ADMIN"
#         "--cap-add=NET_RAW"
#       ];
#     };
#   };

#  system.activationScripts.mkPiholeNetwork = let
# #    myDocker = config.virtualisation.oci-containers.backend;
#    #    dockerBin = "${pkgs.${myDocker}}/bin/${myDocker}";
#  # in ''
#  #    ${pkgs.podman}/bin/podman network create --subnet=192.168.178.0/24 macvlan_test2
#  #  '';
#   in ''
#     ${pkgs.podman}/bin/podman network create -d macvlan \
#       --subnet=192.168.178.0/24 \
#       --gateway=192.168.178.1 \
#       -o parent=wlp4s0 \
#       macvlan_test1
#   '';
#       --ip-range=192.168.178.150/32 \

  systemd.services.init-pihole-network = {
    description = "Create the network for pihole.";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "oneshot";
    script = ''
      # Put a true at the end to prevent getting non-zero return code, which will
      # crash the whole service.
      check=$(${pkgs.podman}/bin/podman network ls | grep "macvlan_test2" || true)
      if [ -z "$check" ];
        then ${pkgs.podman}/bin/podman network create --subnet=192.168.178.0/24 macvlan_test2 
        else echo "pihole-network already exists in podman"
      fi
      ''; 
  };
}
