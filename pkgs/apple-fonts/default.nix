{
  lib,
  xorg,
  stdenvNoCC,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "apple-fonts";
  version = "1.0";

  src = ./.;

  nativeBuildInputs = [
    xorg.mkfontscale
    xorg.mkfontdir
  ];

  installPhase = ''
    mkdir -p $out/share/fonts;
    mkdir -p $out/share/fonts/opentype

    find $src -name "*.otf" -exec install -Dm644 {} -t $out/share/fonts/opentype \;

    mkfontscale "$out/share/fonts/opentype"
    mkfontdir "$out/share/fonts/opentype"
  '';

  meta = with lib; {
    homepage = "https://developer.apple.com/fonts";
    description = "Apple Fonts for nixOS";
    platforms = platforms.all;
    license = licenses.unfree;
  };
}
