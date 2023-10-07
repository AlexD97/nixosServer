# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, builtins, ... }:
let
  user = "alexander";
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./zsh.nix
      ./desktop/borgbackup
      ./syncthing.nix
      ./server/timers/org_calendar_export.nix
      ./server/timers/julia_scripts.nix
      ./server/immich.nix
      ./server/pihole.nix
      ./server/ssl.nix
      ./server/nginx.nix
      ./server/nut.nix
      ./server/smb.nix
      ./server/paperless.nix
      ./server/ntfy.nix
      ./server/healthchecks.nix
      ./server/smart.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
#  boot.loader.efi.efiSysMountPoint = "/boot/EFI";

  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "nixosServer"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;
  #networking.networkmanager.wifi.scanRandMacAddress = false;

  # networking.interfaces.enp1s0.ipv4.addresses = [
  #   { address = "192.168.178.24"; 
  #     prefixLength = 24;
  #   }
  # ];

  # networking.defaultGateway = {
  #   address = "192.168.178.1";
  #   interface = "enp1s0";
  # };

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n.defaultLocale = "de_DE.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  # Configure keymap in X11
   services.xserver = {
    layout = "de";
    xkbVariant = "neo";
  };

  # Configure console keymap
  console.keyMap = "neo";

  services.avahi.enable = true;
  # Important to resolve .local domains of printers, otherwise you get an error
  # like  "Impossible to connect to XXX.local: Name or service not known"
  services.avahi.nssmdns = true;

  environment.variables = {
    QT_QPA_PLATFORM="wayland-egl";
  };

  environment.sessionVariables = {
    EDITOR = "emacsclient -nw -c -F '((font . \"Iosevka-12\"))' -a 'emacs -nw'";
  };

  environment.pathsToLink = [ "/share/zsh" ];

  # SSD trim
  services.fstrim.enable = lib.mkDefault true;

  # NTFS support
  boot.supportedFilesystems = [ "ntfs" ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${user} = {
    isNormalUser = true;
    description = "alexander";
    extraGroups = [ "networkmanager" "wheel" "users" ];
    packages = with pkgs; [
      git
    ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIONP4gaWbdIgR+CWkNA8Lb1n1wQ/or7xuF+OI6x4AuZk alexander"
    ];
  };

  # Automatic login
  services.getty.autologinUser = "${user}";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    git
    clang
    gcc
    julia-bin
    wget
    curl
    pass
    pass-secret-service
    htop
    pciutils
    usbutils
    samba
    unzip
    lsof
    nut

  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
   programs.gnupg.agent = {
     enable = true;
  #   enableSSHSupport = true;
   };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  nix = {
    #package = pkgs.nixVersions.stable;
    extraOptions = "experimental-features = nix-command flakes";
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

}
