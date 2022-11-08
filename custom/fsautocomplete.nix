{ config, pkgs, ...}:
let
  fsautocomplete =
    let
      dotnet = pkgs.dotnetCorePackages.sdk_6_0;

      fsautocomplete-dll = pkgs.stdenvNoCC.mkDerivation {
        name = "fsautocomplete-dll";
        src = pkgs.fetchurl {
          url = "https://github.com/fsharp/FsAutoComplete/releases/download/v0.57.0/fsautocomplete.0.57.0.nupkg";
          sha256 = "0vdfxwj853mn4746r8lis3zvk3w6x3zsdlgg6a95kpb8nrq2fzwr";
        };
        nativeBuildInputs = [ pkgs.unzip ];
        dontUnpack = true;
        dontBuild = true;
        dontFixup = true;

        installPhase = ''
          mkdir -p $out/bin $out/share
          unzip $src -d $out/share
          echo $out/share/tools
        '';
      };
    in
    pkgs.writeShellApplication {
      name = "fsautocomplete";
      runtimeInputs = [
        dotnet
        fsautocomplete-dll
      ];
      text = ''
        export DOTNET_ROOT=${dotnet}
        unset DOTNET_SYSTEM_GLOBALIZATION_INVARIANT
        dotnet ${fsautocomplete-dll}/share/tools/net6.0/any/fsautocomplete.dll "$@"
      '';
    };

in
{
  home.packages = with pkgs; [
    fsautocomplete
  ];
}
