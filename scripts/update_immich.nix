{config, pkgs, ...}:

let 
  update-immich = pkgs.writeShellScriptBin "update-immich" ''
    sudo docker pull ghcr.io/immich-app/immich-server:release
    sudo docker pull ghcr.io/immich-app/immich-web:release
    sudo docker pull ghcr.io/immich-app/immich-proxy:release
    sudo docker pull ghcr.io/immich-app/immich-machine_learning:release

    systemctl restart docker-immich_server.service
    systemctl restart docker-immich_web.service
    systemctl restart docker-immich_proxy.service
    systemctl restart docker-immich_microservices.service
    systemctl restart docker-immich_machine_learning.service

    sudo docker system prune -f
    '';
in
{
  environment.systemPackages = with pkgs; [ update-immich ];
}

