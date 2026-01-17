{ stdenv, lib }:

stdenv.mkDerivation {
  pname = "open-gorton-font";
  version = "1.0";

  src = ../fonts;

  installPhase = ''
    mkdir -p $out/share/fonts/opentype
    cp *.otf $out/share/fonts/opentype/
  '';

  meta = with lib; {
    description = "Open Gorton - Open source keycap font based on Gorton Modified";
    homepage = "https://github.com/dakotafelder/open-gorton";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
