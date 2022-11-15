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
      epkgs.vertico
      epkgs.consult
      epkgs.marginalia
      epkgs.embark
      epkgs.company
      epkgs.company-quickhelp
      epkgs.corfu
      epkgs.corfu-doc
      epkgs.ripgrep

      epkgs.all-the-icons
      epkgs.all-the-icons-dired
      epkgs.svg-tag-mode
      epkgs.rainbow-delimiters
      epkgs.org-bullets
      epkgs.ligature

      epkgs.bind-key
      epkgs.use-package
      epkgs.yasnippet

      epkgs.eglot-jl
      epkgs.fsharp-mode
      epkgs.eglot-fsharp
      epkgs.nix-mode
      epkgs.lsp-mode

      epkgs.auctex-latexmk

      epkgs.org-roam
      epkgs.emacsql
      epkgs.emacsql-sqlite
      epkgs.emacsql-sqlite3
      epkgs.org-journal
      epkgs.one-themes
    ];
  };

  services.emacs.enable = true;

  home.file.".emacs".source = ./emacs_config;
}
