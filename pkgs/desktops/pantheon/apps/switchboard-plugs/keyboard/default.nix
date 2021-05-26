{ stdenv
, fetchFromGitHub
, pantheon
, fetchpatch
, substituteAll
, meson
, ninja
, pkgconfig
, vala
, libgee
, granite
, gtk3
, libxml2
, libgnomekbd
, libxklavier
, xorg
, ibus
, switchboard
}:

stdenv.mkDerivation rec {
  pname = "switchboard-plug-keyboard";
  version = "2.4.1";

  src = fetchFromGitHub {
    owner = "elementary";
    repo = pname;
    rev = version;
    sha256 = "04wn9rj11wvl4qxc2mq8sfdy3zkbqvxzr0f22vrbbypgkqszkswa";
  };

  patches = [
    ./0001-Remove-Install-Unlisted-Engines-function.patch
  ];

  passthru = {
    updateScript = pantheon.updateScript {
      attrPath = "pantheon.${pname}";
    };
  };

  nativeBuildInputs = [
    libxml2
    meson
    ninja
    pkgconfig
    vala
  ];

  buildInputs = [
    granite
    gtk3
    ibus
    libgee
    libgnomekbd
    libxklavier
    switchboard
  ];

  meta = with stdenv.lib; {
    description = "Switchboard Keyboard Plug";
    homepage = https://github.com/elementary/switchboard-plug-keyboard;
    license = licenses.gpl2Plus;
    platforms = platforms.linux;
    maintainers = pantheon.maintainers;
  };
}
