{ cobalt, html-minifier, lib, meson, minify_html ? true, minify_css ? true, ninja, nix-gitignore, poppins, stdenv, tailwindcss_4, woff2 }:

stdenv.mkDerivation {
  name = "compsoc-website";

  src = builtins.path {
    name = "source";
    path = ./.;
    filter = nix-gitignore.gitignoreFilterPure (_: _: true) [
      ".gitignore"
      "*.nix"
      "flake.lock"
      "/setup"
      "/watch"
    ] ./.;
  };

  mesonFlags =
    [ "-Dpoppins_src=${poppins}/share/fonts/truetype/" ]
    ++ lib.optional (!minify_html) "-Dminify_html=disabled"
    ++ lib.optional (!minify_css) "-Dminify_css=false";

  nativeBuildInputs = [ cobalt meson ninja tailwindcss_4 woff2 ] ++ lib.optional minify_html html-minifier;

  __structuredAttrs = true;
}
