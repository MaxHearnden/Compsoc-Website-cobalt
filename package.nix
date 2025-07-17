{ cobalt, html-minifier, lib, meson, ninja, nix-gitignore, poppins, simple-http-server, stdenv, tailwindcss_4, woff2 }:

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

  mesonFlags = [ "-Dpoppins_src=${poppins}/share/fonts/truetype/" ];

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

  nativeBuildInputs = [ cobalt html-minifier meson ninja tailwindcss_4 woff2 ];

  __structuredAttrs = true;
}
