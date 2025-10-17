{
  description = "OBS Image Reaction Plugin";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages.default = pkgs.stdenv.mkDerivation {
          pname = "obs-image-reaction";
          version = "1.0";

          src = ./.;

          nativeBuildInputs = with pkgs; [
            cmake
            pkg-config
          ];

          buildInputs = with pkgs; [
            obs-studio
          ];

          cmakeFlags = [
            "-DBUILD_OUT_OF_TREE=On"
            "-DLIBOBS_INCLUDE_DIR=${pkgs.obs-studio}/include/obs"
            "-DLIBOBS_LIB=${pkgs.obs-studio}/lib"
          ];

          postUnpack = ''
            sed -i 's/find_package(LibObs REQUIRED)/# LibObs config provided via CMake flags/' $sourceRoot/CMakeLists.txt
            sed -i 's|''${LIBOBS_LIBRARIES}|obs|g' $sourceRoot/CMakeLists.txt
            sed -i 's|''${OBS_FRONTEND_LIB}||g' $sourceRoot/CMakeLists.txt
          '';

          installPhase = ''
            mkdir -p $out/lib/obs-plugins
            mkdir -p $out/share/obs/obs-plugins/obs-image-reaction

            cp libimage-reaction.so $out/lib/obs-plugins/
            cp -r ../data $out/share/obs/obs-plugins/obs-image-reaction/
          '';

          meta = with pkgs.lib; {
            description = "OBS plugin for images that react to sound sources";
            homepage = "https://github.com/scaledteam/obs-image-reaction";
            license = licenses.gpl2Plus;
            platforms = pkgs.obs-studio.meta.platforms;
          };
        };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            cmake
            pkg-config
            obs-studio
          ];
        };
      }
    );
}
