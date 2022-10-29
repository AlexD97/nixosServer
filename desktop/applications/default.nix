{ pkgs, ... }:
{
  xdg.configFile."sioyek/keys_user.config".source = ./sioyek_keys_user.config;
  xdg.configFile."sioyek/prefs_user.config".source = ./sioyek_prefs_user.config;
}
