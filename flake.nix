{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { nixpkgs, self }:
    let inherit (nixpkgs) legacyPackages lib;
    in {
      apps = lib.mapAttrs (system: pkgs: {
        default = {
          program = lib.getExe (pkgs.writeShellScriptBin "web-server" ''
            ${lib.getExe pkgs.simple-http-server} -i "$@" -- ${self.packages.${system}.default}
          '');
          type = "app";
        };
      }) legacyPackages;

      devShells = lib.mapAttrs (system: pkgs: {
        default = self.packages.${system}.default.overrideAttrs (
          { nativeBuildInputs ? [], ... }: {
            nativeBuildInputs = nativeBuildInputs ++ [ pkgs.watchexec ];
            src = null;
          });
      }) legacyPackages;

      packages = lib.mapAttrs (system: pkgs: {
        default = pkgs.callPackage ./package.nix { };
      }) legacyPackages;
    };
}