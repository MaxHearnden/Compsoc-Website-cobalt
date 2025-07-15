{ cobalt, lib, nix-gitignore, orbitron, poppins, simple-http-server, stdenv, tailwindcss_4, woff2 }:

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

    cp ${orbitron}/share/fonts/opentype/Orbitron\ Light.otf $out/orbitron.otf
    cp ${poppins}/share/fonts/truetype/Poppins-Light.ttf $out/poppins.ttf
    woff2_compress $out/orbitron.otf
    woff2_compress $out/poppins.ttf
  '';

  nativeBuildInputs = [ cobalt tailwindcss_4 woff2 ];

  pages = [ "index" "about" ];

  __structuredAttrs = true;
}