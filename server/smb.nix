{ config, lib, pkgs, ... }:
let

in {
  # services.samba-wsdd.enable = true; # make shares visible for windows 10 clients
  # networking.firewall.allowedTCPPorts = [
  #   445
  #   139
  #   5357 # wsdd
  # ];
  # networking.firewall.allowedUDPPorts = [
  #   137
  #   138
  #   3702 # wsdd
  # ];
  # services.samba = {
  #   enable = true;
  #   enableNmbd = true;
  #   securityType = "user";
  #   extraConfig = ''
  #     workgroup = WORKGROUP
  #     server string = smbnix
  #     netbios name = smbnix
  #     security = user 
  #     #use sendfile = yes
  #     #max protocol = smb2
  #     # note: localhost is the ipv6 localhost ::1
  #     hosts allow = 192.168.0. 127.0.0.1 localhost
  #     hosts deny = 0.0.0.0/0
  #     guest account = nobody
  #     map to guest = bad user
  #   '';
  #   shares = {
  #   #   public = {
  #   #     path = "/mnt/Shares/Public";
  #   #     browseable = "yes";
  #   #     "read only" = "no";
  #   #     "guest ok" = "yes";
  #   #     "create mask" = "0644";
  #   #     "directory mask" = "0755";
  #   #     "force user" = "username";
  #   #     "force group" = "groupname";
  #   #   };
  #     private = {
  #       path = "/home/alexander/Dokumente";
  #       browseable = "yes";
  #       "read only" = "no";
  #       "guest ok" = "no";
  #       "create mask" = "0644";
  #       "directory mask" = "0755";
  #       "force user" = "username";
  #       "force group" = "groupname";
  #     };
  #   };
  # };
  services.samba = {
    enable = true;
    package = pkgs.samba4Full;
    # securityType = "user";
    # invalidUsers = [ "root" ];
    openFirewall = true;
    settings = {
      global = {
        "invalid users" = [ "root" ];
        "security" = "user";
        "workgroup" = "WORKGROUP";
        "server string" = "smbnix";
        "server role" = "standalone server";
      };
      sharedfolders = {
        "path" = "/sharedfolders";
        "public" = "no";
        "writable" = "yes";
        "browseable" = "yes";
        "comment" = "server1 /sharedfolders samba share.";
      };
    };
    # extraConfig = ''
    #   workgroup = WORKGROUP
    #   server string = smbnix
    #   server role = standalone server
    # '';
    # shares = {
    #   sharedfolders = { 
    #     path = "/sharedfolders";
    #     public = "no";
    #     writable = "yes";
    #     browseable = "yes";
    #     comment = "server1 /sharedfolders samba share.";
    #   };
    # };
  };

  services.samba-wsdd = {
    enable = true;
    discovery = true;  
    openFirewall = true;
    extraOptions = [
      "--verbose"
    ];
  };

  networking.firewall = {
    allowedTCPPorts = [ 137 138 139 389 445 ];
    allowedUDPPorts = [ 137 138 139 389 445 ];
  };
}
