{pkgs, ... }:
let

in {
  services.ntfy-sh = {
    enable = true;
    settings = {
      listen-http = ":8123";
      base-url = "https://ntfy.alexanderdinges.de";
#      cache-file = "/home/alexander/Downloads/ntfy_cache.db";
      cache-duration = "48h";
    };
  };
}
