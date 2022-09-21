{ config, pkgs, ... }: {
  programs.emacs = {
    enable = true;
    extraPackages = epkgs : [ epkgs.vterm ];
  };

  home.file.".emacs".source = ./emacs_config;
}
