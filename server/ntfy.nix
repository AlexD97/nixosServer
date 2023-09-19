{pkgs, ... }:
let

in {
  services.ntfy = {
    enable = true;
    settings = {
      listen-http = ":8123";
    };
  };
}
