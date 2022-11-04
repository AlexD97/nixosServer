{ config, pkgs, ... }: {
  programs.emacs = {
    enable = true;
    package = pkgs.emacsPgtkNativeComp;
    extraPackages = epkgs : [
      epkgs.vterm
      epkgs.async
      epkgs.vterm-toggle

      epkgs.undo-tree
      epkgs.olivetti
      epkgs.counsel
      epkgs.swiper
      epkgs.ripgrep

      epkgs.all-the-icons
      epkgs.all-the-icons-dired
      epkgs.svg-tag-mode
      epkgs.rainbow-delimiters
      epkgs.org-bullets

      epkgs.bind-key
      epkgs.use-package

      epkgs.eglot-jl
      epkgs.fsharp-mode
      epkgs.eglot-fsharp
      epkgs.nix-mode
      epkgs.lsp-mode

      epkgs.org-roam
      epkgs.org-journal
      epkgs.one-themes
    ];
  };

  services.emacs.enable = true;

  home.file.".emacs".source = ./emacs_config;
}
