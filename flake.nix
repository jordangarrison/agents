{
  description = "Personal micro agents codebase";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

  outputs = { nixpkgs, ... }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
      himalayaFor = system:
        nixpkgs.legacyPackages.${system}.himalaya.override {
          buildFeatures = [ "keyring" "oauth2" ];
        };
    in {
      packages = forAllSystems (system: {
        himalaya = himalayaFor system;
      });

      checks = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          himalaya = himalayaFor system;
        in {
          himalaya-contract = pkgs.runCommand "himalaya-contract" {
            nativeBuildInputs = [ himalaya pkgs.gnugrep ];
          } ''
            version_output="$(himalaya --version)"
            echo "$version_output"
            echo "$version_output" | grep -F "himalaya v1.2.0"
            echo "$version_output" | grep -F "+keyring"
            echo "$version_output" | grep -F "+oauth2"
            touch "$out"
          '';
        });

      devShells = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          himalaya = himalayaFor system;
        in {
          default = pkgs.mkShell {
            packages = [
              pkgs.bun
              pkgs.ffmpeg
              pkgs.openai-whisper
              himalaya
            ];
          };
        });
    };
}
