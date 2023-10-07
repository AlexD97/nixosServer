{pkgs, config, lib, ... }:
let

in {
  services.healthchecks = {
    enable = true;
    port = 3892;
#    listenAddress = "0.0.0.0";
    settings = {
      SECRET_KEY_FILE = "/var/lib/healthchecks/healthchecks_password";
      INTEGRATIONS_ALLOW_PRIVATE_IPS = "True";
    };
  };

  # systemd.services = {
  #   healthchecks = let
  #     cfg = config.services.healthchecks;
  #     pkg = cfg.package;
  #   in {
  #     preStart = lib.mkForce ''
  #       ${pkg}/opt/healthchecks/manage.py collectstatic --no-input
  #       ${pkg}/opt/healthchecks/manage.py remove_stale_contenttypes --no-input
  #       ${pkg}/opt/healthchecks/manage.py compress --force
  #     '';
  #   };
  # };
}

# create superuser with healthchecks-manage createsuperuser
