{ config, pkgs, ... }: {
  programs.emacs = {
    enable = true;
    package = pkgs.emacsPgtkNativeComp;
    extraPackages = epkgs : [ epkgs.vterm epkgs.async ];
  };

  services.emacs.enable = true;

  home.file.".emacs".source = ./emacs_config;
}
