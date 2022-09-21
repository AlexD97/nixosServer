inputs@{ config, pkgs, ... }:

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
  home.stateVersion = "22.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  imports = [
    ./desktop/newm
  ];

  home.sessionVariables = { QT_QPA_PLATFORM="wayland-egl"; };

  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    alacritty
    emacs
    vlc
    syncthingtray
    warpd

    udiskie
    jmtpfs
    ntfs3g

    libappindicator
    pavucontrol

    julia-bin
    
    (nerdfonts.override { fonts = ["FiraCode" "DroidSansMono" "Iosevka" "SourceCodePro" ]; })

    borgbackup
    vorta
  ];

  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; with inputs.vscode-marketplace.packages.${inputs.system}.vscode; [
      james-yu.latex-workshop
      julialang.language-julia
    ];
  };

  services = {
    kdeconnect = {
      enable = true;
      indicator = true;
    };
    syncthing = {
      enable = true;
      tray = {
        enable = true;
        command = "syncthingtray --wait";
      };
    };
  };

  systemd.user.targets.tray = {
    Unit = {
      Description = "Home Manager System Tray";
      Requires = [ "graphical-session-pre.target" ];
    };
  };

}
