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
          ];

          postInstall = ''
            rm -rf $out/obs-plugins $out/data
          '';

          meta = with pkgs.lib; {
            description = "OBS plugin for images that react to sound sources";
            homepage = "https://github.com/scaledteam/obs-image-reaction";
            license = licenses.gpl2Plus;
            platforms = obs-studio.meta.platforms;
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
