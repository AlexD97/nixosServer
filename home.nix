inputs@{ config, pkgs, lib, ... }:

let
  my-python-packages = python-packages: with python-packages; [
    # other python packages you want
  ];
  python-with-my-packages = pkgs.python3.withPackages my-python-packages;
in

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "alexander";
  home.homeDirectory = "/home/alexander";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "23.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  imports = [
    ./desktop/emacs
    # ./zsh.nix
  ];

  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    #emacs
    sqlite
    ripgrep
    #ripgrep-all

    #python3
    python-with-my-packages
    #julia-bin
    gnumake
    nil
    
    zsh
    fzf
    zsh-powerlevel10k
    moreutils
    bc
    recode

    emacs-all-the-icons-fonts
    material-design-icons
    #(nerdfonts.override { fonts = ["FiraCode" "DroidSansMono" "Iosevka" "SourceCodePro" "JetBrainsMono" ]; })
    nerd-fonts.fira-code
    nerd-fonts.droid-sans-mono
    nerd-fonts.iosevka
    nerd-fonts.sauce-code-pro
    nerd-fonts.jetbrains-mono
    #iosevka-fixed
    #iosevka-fixed-slab
    (iosevka-bin.override { variant = "SGr-IosevkaFixed"; } )
    (iosevka-bin.override { variant = "SGr-IosevkaFixedCurlySlab"; } )
    alegreya
    alegreya-sans
    gyre-fonts
    libertinus
    xits-math

    texlive.combined.scheme-full
    lhs2tex

    pandoc

    borgbackup
  ];
}
