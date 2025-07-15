{ cobalt, html-minifier, lib, nix-gitignore, orbitron, poppins, simple-http-server, stdenv, tailwindcss_4, woff2 }:

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
      tailwindcss -m --cwd _site -i css/"$page".css -o "$page"_final.css
    done

    cp ${orbitron}/share/fonts/opentype/Orbitron\ Light.otf _site/orbitron.otf
    cp ${poppins}/share/fonts/truetype/Poppins-Light.ttf _site/poppins.ttf
    woff2_compress _site/orbitron.otf
    woff2_compress _site/poppins.ttf
  '';

  installPhase = ''
    mkdir $out
    cp -r _site/img $out
    for page in "''${pages[@]}"; do
      cp _site/"$page"_final.css $out
      html-minifier "''${minifierArgs[@]}" "_site/$page.html" -o "$out/$page.html"
    done

    cp _site/orbitron.woff2 _site/poppins.woff2 $out
  '';

  minifierArgs = [
    "--collapse-inline-tag-whitespace"
    "--collapse-whitespace"
    "--decode-entities"
    "--remove-attribute-quotes"
    "--remove-comments"
    "--remove-empty-elements"
    "--remove-optional-tags"
    "--remove-redundant-attributes"
    "--remove-tag-whitespace"
  ];

  nativeBuildInputs = [ cobalt html-minifier tailwindcss_4 woff2 ];

  pages = [ "index" "about" ];

  __structuredAttrs = true;
}