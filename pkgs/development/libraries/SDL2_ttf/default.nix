{ lib, stdenv, pkg-config, darwin, fetchurl, SDL2, freetype, harfbuzz, libGL }:

stdenv.mkDerivation rec {
  pname = "SDL2_ttf";
  version = "2.20.2";

  src = fetchurl {
    url = "https://www.libsdl.org/projects/SDL_ttf/release/${pname}-${version}.tar.gz";
    sha256 = "sha256-ncce2TSHUhsQeixKnKa/Q/ti9r3dXCawVea5FBiiIFM=";
  };

  configureFlags = [ "--disable-harfbuzz-builtin" ]
    ++ lib.optionals stdenv.isDarwin [ "--disable-sdltest" ];

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ SDL2 freetype harfbuzz ]
    ++ lib.optional (!stdenv.isDarwin) libGL
    ++ lib.optional stdenv.isDarwin darwin.libobjc;

  meta = with lib; {
    description = "Support for TrueType (.ttf) font files with Simple Directmedia Layer";
    platforms = platforms.unix;
    license = licenses.zlib;
    homepage = "https://github.com/libsdl-org/SDL_ttf";
  };
}
