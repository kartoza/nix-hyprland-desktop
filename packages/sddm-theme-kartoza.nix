{ pkgs, wallpaper }:

pkgs.stdenv.mkDerivation {
  pname = "sddm-theme-kartoza";
  version = "1.0";

  src = ../dotfiles/sddm/themes/kartoza;

  buildInputs = with pkgs.kdePackages; [
    qtbase
    qtsvg
    qtdeclarative
    qt5compat
    qtwayland
  ];

  dontBuild = true;
  dontConfigure = true;
  dontWrapQtApps = true; # This is a theme, not an application

  installPhase = ''
    mkdir -p $out/share/sddm/themes/kartoza

    # Copy theme files
    cp -r $src/* $out/share/sddm/themes/kartoza/

    # Fix wallpaper path in theme.conf to use the configured wallpaper
    substituteInPlace $out/share/sddm/themes/kartoza/theme.conf \
      --replace "/etc/xdg/backgrounds/kartoza-wallpaper.png" "${wallpaper}"

    # Fix wallpaper path in Main.qml
    substituteInPlace $out/share/sddm/themes/kartoza/Main.qml \
      --replace "/etc/xdg/backgrounds/kartoza-wallpaper.png" "${wallpaper}"
  '';

  meta = with pkgs.lib; {
    description = "Kartoza branded SDDM theme";
    homepage = "https://kartoza.com";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
