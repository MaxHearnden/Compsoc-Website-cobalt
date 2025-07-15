{ cobalt, lib, nix-gitignore, simple-http-server, stdenv, tailwindcss_4 }:

stdenv.mkDerivation {
  name = "compsoc-website";

  outputs = [ "out" ];

  src = builtins.path {
    name = "source";
    path = ./.;
    filter = nix-gitignore.gitignoreFilterPure (_: _: true) [
      ".gitignore"
      "*.nix"
      "flake.lock"
    ] ./.;
  };

  buildPhase = ''
    cobalt build

    tailwindcss --cwd _site -i index.css -o index_final.css
  '';

  installPhase = ''
    mkdir $out
    cp -r _site/img _site/index_final.css _site/index.html $out
  '';

  nativeBuildInputs = [ cobalt tailwindcss_4 ];
}