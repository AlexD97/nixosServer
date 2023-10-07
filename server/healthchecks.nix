{pkgs, ... }:
let

in {
  services.healthchecks = {
    enable = true;
    port = 3892;
    settings = {
      SECRET_KEY_FILE = "/var/lib/healthchecks/healthchecks_password";
      REGISTRATION_OPEN = true;
      INTEGRATIONS_ALLOW_PRIVATE_IPS = "True";
    };
  };
}
