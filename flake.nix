{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = github:nix-community/home-manager;
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur.url = "github:nix-community/nur";
    newmpkg.url = "github:jbuchermn/newm";
    newmpkg.inputs.nixpkgs.follows = "nixpkgs";
    pywm-fullscreenpkg.url = "github:jbuchermn/pywm-fullscreen";
    pywm-fullscreenpkg.inputs.nixpkgs.follows = "nixpkgs";

    emacs-overlay.url = "github:nix-community/emacs-overlay";

    vscode-marketplace.url = "github:ameertaweel/nix-vscode-marketplace";

  };

  outputs = { self, nixpkgs, home-manager, nur, newmpkg, pywm-fullscreenpkg, vscode-marketplace, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [
          nur.overlay
          (self: super: {
            newm = newmpkg.packages.x86_64-linux.newm;
            pywm-fullscreen = pywm-fullscreenpkg.packages.x86_64-linux.pywm-fullscreen;
          })
          (import self.inputs.emacs-overlay)

          (self: super: {
            iosevka-fixed = super.iosevka.override { set = "fixed"; };
            iosevka-fixed-slab = super.iosevka.override { set = "fixed-slab"; };
          })

          (self: super: {
            my-fsautocomplete = super.callPackage ./custom/fsautocomplete.nix { self.pkgs };
          })

          /*(self: super: {
            my-custom-snip = super.callPackage ./custom/snip.nix { };
          })*/
        ];
      };
      lib = nixpkgs.lib;

    in {
      nixosConfigurations = {
        alexander = lib.nixosSystem {
          inherit system pkgs;
          modules = [ 
           ./configuration.nix
           home-manager.nixosModules.home-manager {
             home-manager.useGlobalPkgs = true;
             home-manager.useUserPackages = true;
             home-manager.users.alexander = {
               imports = [ ./home.nix ];
             };
             home-manager.extraSpecialArgs = {
               inherit pkgs vscode-marketplace system;
             };
           }
          ];
        };
      };
      
    };
    
}
