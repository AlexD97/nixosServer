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

  };

  outputs = { self, nixpkgs, home-manager, nur, newmpkg, pywm-fullscreenpkg, ... }:
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
        ];
      };
      lib = nixpkgs.lib;

    in {
      nixosConfigurations = {
        alexander = lib.nixosSystem {
          inherit system;
          modules = [ 
           ./configuration.nix 
           home-manager.nixosModules.home-manager {
             #home-manager.useGlobalPkgs = true;
             home-manager.useUserPackages = true;
             home-manager.users.alexander = {
               imports = [ ./home.nix ];
             };
             home-manager.extraSpecialArgs = {
               inherit pkgs;
             };
           }
          ];
        };
      };
      
    };
    
}
