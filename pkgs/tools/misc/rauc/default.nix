{ autoreconfHook
, curl
, dbus
, fetchFromGitHub
, glib
, json-glib
, lib
, nix-update-script
, openssl
, pkg-config
, stdenv
}:

stdenv.mkDerivation rec {
  pname = "rauc";
  version = "1.8";

  src = fetchFromGitHub {
    owner = pname;
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-lSTC/WDwa6WVPd+Tj6XdKpwwENfAweUnE6lCyXQvAXU=";
  };

  passthru = {
    updateScript = nix-update-script { };
  };

  enableParallelBuilding = true;

  nativeBuildInputs = [ pkg-config autoreconfHook ];

  buildInputs = [ curl dbus glib json-glib openssl ];

  configureFlags = [
    "--with-systemdunitdir=${placeholder "out"}/lib/systemd/system"
    "--with-dbusinterfacesdir=${placeholder "out"}/share/dbus-1/interfaces"
    "--with-dbuspolicydir=${placeholder "out"}/share/dbus-1/system.d"
    "--with-dbussystemservicedir=${placeholder "out"}/share/dbus-1/system-services"
  ];

  meta = with lib; {
    description = "Safe and secure software updates for embedded Linux";
    homepage = "https://rauc.io";
    license = licenses.lgpl21Only;
    maintainers = with maintainers; [ emantor ];
    platforms = with platforms; linux;
  };
}
