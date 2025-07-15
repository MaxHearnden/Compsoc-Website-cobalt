{ cobalt, lib, nix-gitignore, orbitron, poppins, simple-http-server, stdenv, tailwindcss_4 }:

stdenv.mkDerivation {
  name = "compsoc-website";

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

    for page in "''${pages[@]}"; do
      tailwindcss --cwd _site -i "$page".css -o "$page"_final.css
    done
  '';

  installPhase = ''
    mkdir $out
    cp -r _site/img $out
    for page in "''${pages[@]}"; do
      cp -r "_site/''${page}_final.css" "_site/$page.html" $out
    done
    cp -r ${orbitron}/share/fonts/opentype $out/orbitron
    cp -r ${poppins}/share/fonts/truetype $out/Poppins
  '';

  nativeBuildInputs = [ cobalt tailwindcss_4 ];

  pages = [ "index" "about" ];

  __structuredAttrs = true;
}