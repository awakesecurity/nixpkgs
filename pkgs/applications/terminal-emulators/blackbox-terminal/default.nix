{ lib
, stdenv
, fetchFromGitLab
, fetchurl
, meson
, ninja
, pkg-config
, vala
, gtk4
, vte-gtk4
, json-glib
, sassc
, libadwaita
, pcre2
, libxml2
, librsvg
, libgee
, callPackage
, python3
, gtk3
, desktop-file-utils
, wrapGAppsHook
}:

let
  marble = callPackage ./marble.nix { };
in
stdenv.mkDerivation rec {
  pname = "blackbox";
  version = "0.14.0";

  src = fetchFromGitLab {
    domain = "gitlab.gnome.org";
    owner = "raggesilver";
    repo = "blackbox";
    rev = "v${version}";
    hash = "sha256-ebwh9WTooJuvYFIygDBn9lYC7+lx9P1HskvKU8EX9jw=";
  };

  postPatch = ''
    patchShebangs build-aux/meson/postinstall.py
  '';

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    vala
    sassc
    wrapGAppsHook
    python3
    gtk3 # For gtk-update-icon-cache
    desktop-file-utils # For update-desktop-database
  ];
  buildInputs = [
    gtk4
    vte-gtk4
    json-glib
    marble
    libadwaita
    pcre2
    libxml2
    librsvg
    libgee
  ];

  mesonFlags = [ "-Dblackbox_is_flatpak=false" ];

  meta = with lib; {
    description = "Beautiful GTK 4 terminal";
    homepage = "https://gitlab.gnome.org/raggesilver/blackbox";
    changelog = "https://gitlab.gnome.org/raggesilver/blackbox/-/raw/v${version}/CHANGELOG.md";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ chuangzhu ];
    platforms = platforms.linux;
  };
}
