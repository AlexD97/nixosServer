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
      epkgs.orderless
      epkgs.consult
      epkgs.affe
      epkgs.marginalia
      epkgs.embark
      #epkgs.company
      #epkgs.company-quickhelp
      epkgs.corfu
      #epkgs.corfu-doc
      epkgs.cape
      epkgs.ripgrep

      epkgs.htmlize
      epkgs.all-the-icons
      epkgs.all-the-icons-dired
      epkgs.dired-hide-dotfiles
      epkgs.svg-tag-mode
      epkgs.rainbow-delimiters
      epkgs.org-bullets
      epkgs.ligature

      epkgs.quelpa
      epkgs.bind-key
      epkgs.use-package
      epkgs.yasnippet

      epkgs.notmuch

      epkgs.eglot-jl
      epkgs.fsharp-mode
      epkgs.eglot-fsharp
      epkgs.nix-mode
      epkgs.lsp-mode

      #epkgs.auctex-latexmk

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
  #home.file.".emacs".source = config.lib.file.mkOutOfStoreSymlink ./emacs_config;
}
