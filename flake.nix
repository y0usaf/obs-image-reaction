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
          ];

          buildInputs = with pkgs; [
            obs-studio
          ];

          cmakeFlags = [
            "-DBUILD_OUT_OF_TREE=On"
          ];

          # Work around missing LibObs CMake config by providing minimal stub
          preConfigure = ''
            mkdir -p cmake
            cat > cmake/FindLibObs.cmake <<'EOF'
              set(LIBOBS_INCLUDE_DIR ${pkgs.obs-studio}/include/obs)
              set(LIBOBS_LIB ${pkgs.obs-studio}/lib)
              set(LIBOBS_LIBRARIES obs)
              set(OBS_FRONTEND_LIB "")
              set(LibObs_FOUND TRUE)
            EOF
            export CMAKE_MODULE_PATH="$PWD/cmake:$CMAKE_MODULE_PATH"
          '';

          installPhase = ''
            mkdir -p $out/lib/obs-plugins
            mkdir -p $out/share/obs/obs-plugins/obs-image-reaction

            cp libimage-reaction.so $out/lib/obs-plugins/
            cp -r "$sourceRoot/data" "$out/share/obs/obs-plugins/obs-image-reaction/"
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
            obs-studio
          ];
        };
      }
    );
}
