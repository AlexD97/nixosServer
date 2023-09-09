{ self, config, lib, pkgs, ... }:

{
  security.acme = {
    acceptTerms = true;
    defaults.email = "nginxproxymanager@dinges.slmail.me";

    certs."alexanderdinges.de" = {
      domain = "alexanderdinges.de";
      extraDomainNames = [ "*.alexanderdinges.de" ];
      dnsProvider = "netcup";
      dnsPropagationCheck = true;
      credentialsFile = /home/alexander/Downloads/ssl_secret.txt;
    };
  };

  users.users.nginx.extraGroups = [ "acme" ];
}
