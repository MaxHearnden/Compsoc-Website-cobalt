project('compsoc-website', meson_version: '>=1.4')

fs = import('fs')

pages = [
  'index',
  'about',
]

html_minifier = find_program('html-minifier', required: get_option('minify_html'))
tailwindcss = find_program('tailwindcss')

website_files = [
  'about_full.liquid',
  'index_full.liquid',
  '_includes/default.liquid',
  '_includes/footer.liquid',
  '_includes/header.liquid',
  '_includes/join.liquid',
  '_includes/logo-text.liquid',
  '_includes/logo.liquid',
  '_includes/SVG/carbon-arrow-right.liquid',
  '_includes/SVG/discord.liquid',
  '_includes/SVG/external-link.liquid',
  '_includes/SVG/github.liquid',
  '_includes/SVG/icon-black.liquid',
  '_includes/SVG/instagram.liquid',
  '_includes/SVG/star-filled.liquid',
  '_includes/SVG/star.liquid',
  '_layouts/app.liquid',
]

cobalt = custom_target(
  'cobalt',
  input: ['_cobalt.yml'],
  output: ['about_full.html', 'index_full.html'],
  command: ['cobalt', 'build', '-q', '-d', '@OUTDIR@', '-c', '@INPUT@'],
  depend_files: website_files,
  # install: true,
  install_dir: 'cobalt',
)

common_css_sources = [
  'app.css',
  'default.css',
  'fonts.css',
  'footer.css',
  'header.css',
  'join.css',
  'logo-text.css',
  'logo.css',
]

logo_sources = [
  'img/logo/TPP.png',
  'img/logo/full-transparent.webp',
]

common_css_files = []

foreach css_file : common_css_sources
  common_css_files += fs.copyfile('css' / css_file, install_dir: 'css')
endforeach

logos = []

foreach logo : logo_sources
  logos += fs.copyfile(logo, install: true, install_dir: '.')
endforeach

poppins = get_option('poppins_src')

font_sources = [
  ['fonts/orbitron.ttf', 'orbitron.ttf'],
  [poppins / 'Poppins-Light.ttf', 'poppins-light.ttf'],
  [poppins / 'Poppins-Regular.ttf', 'poppins.ttf'],
]

fonts = []

woff2_compress = find_program('woff2_compress')

foreach font : font_sources
  font_tmp = fs.copyfile(font[0], font[1])
  woff2_name = fs.replace_suffix(font_tmp, '.woff2')
  fonts += custom_target(woff2_name, input: [font_tmp], output: [woff2_name], command: [woff2_compress, '@INPUT@'], install: true, install_dir: '.' )
endforeach

minifier_args = [
  '--collapse-inline-tag-whitespace',
  '--collapse-whitespace',
  '--decode-entities',
  '--remove-attribute-quotes',
  '--remove-comments',
  '--remove-empty-elements',
  '--remove-optional-tags',
  '--remove-redundant-attributes',
  '--remove-tag-whitespace',
]

css_files = []

html_files = []

if get_option('minify_css')
  minify_css_argument = ['-m']
else
  minify_css_argument = []
endif

foreach page : cobalt.to_list()
  basename = fs.name(page.full_path()).substring(0, -10)
  css = fs.replace_suffix(basename, '.css')
  css_destination = fs.replace_suffix(basename, '') + '_final.css'
  css_rule = get_option('minify_css') ? css_destination + ' minified' : css_destination
  css_files += custom_target(
    css_rule,
    input: [ fs.copyfile('css' / css) ],
    output: [ css_destination ],
    command: [ tailwindcss, '-i', '@INPUT@', '-o', '@OUTPUT@'] + minify_css_argument,
    depends: [ page ] + common_css_files,
    install: true,
    install_dir: '',
  )
  output_html_filename = fs.replace_suffix(basename, '.html')
  if html_minifier.found()
    html_files += custom_target(
      basename + ' minified',
      input: [page],
      output: [output_html_filename],
      install: true,
      install_dir: '.',
      command: [html_minifier, '@INPUT@', '-o', '@OUTPUT@' ] + minifier_args,
    )
  else
    html_files += custom_target(basename, input: [page], output: [output_html_filename], command: ['cp', '@INPUT@', '@OUTPUT@'], install: true, install_dir: '.')
  endif
endforeach

http_server = find_program('simple-http-server', required: false, disabler: true)

run_target('server', command: [http_server, '-i', '@BUILD_ROOT@'], depends: html_files + css_files + logos + fonts)
