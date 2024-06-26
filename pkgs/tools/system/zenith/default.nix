{ lib
, stdenv
, rustPlatform
, fetchFromGitHub
, IOKit
, nvidiaSupport ? false
, makeWrapper
, llvmPackages
}:

assert nvidiaSupport -> stdenv.isLinux;

rustPlatform.buildRustPackage rec {
  pname = "zenith";
  version = "0.13.1";

  src = fetchFromGitHub {
    owner = "bvaisvil";
    repo = pname;
    rev = version;
    sha256 = "sha256-N/DvPVYGM/DjTvKvOlR60q6rvNyfAQlnvFnFG5nbUmQ=";
  };

  # remove cargo config so it can find the linker on aarch64-linux
  postPatch = ''
    rm .cargo/config
  '';

  cargoSha256 = "sha256-Y/vvRJpv82Uc+Bu3lbZxRsu4TL6sAjz5AWHAHkwh98Y=";

  nativeBuildInputs = [ llvmPackages.clang ] ++ lib.optional nvidiaSupport makeWrapper;
  buildInputs = [ llvmPackages.libclang ] ++ lib.optionals stdenv.isDarwin [ IOKit ];

  buildFeatures = lib.optional nvidiaSupport "nvidia";

  LIBCLANG_PATH = "${llvmPackages.libclang.lib}/lib";

  postInstall = lib.optionalString nvidiaSupport ''
    wrapProgram $out/bin/zenith \
      --suffix LD_LIBRARY_PATH : "/run/opengl-driver/lib"
  '';

  meta = with lib; {
    description = "Sort of like top or htop but with zoom-able charts, network, and disk usage"
      + lib.optionalString nvidiaSupport ", and NVIDIA GPU usage";
    homepage = "https://github.com/bvaisvil/zenith";
    license = licenses.mit;
    maintainers = with maintainers; [ bbigras ];
    platforms = platforms.unix;
  };
}
