{ lib
, stdenvNoCC
, fetchurl
, makeWrapper
, jre_headless
, util-linux
, gnugrep
, coreutils
, autoPatchelfHook
, zlib
, nixosTests
}:

stdenvNoCC.mkDerivation rec {
  pname = "opensearch";
  version = "2.5.0";

  src = fetchurl {
    url = "https://artifacts.opensearch.org/releases/bundle/opensearch/${version}/opensearch-${version}-linux-x64.tar.gz";
    hash = "sha256-WPD5StVBb/hK+kP/1wkQQBKRQma/uaP+8ULeIFUBL1U=";
  };

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ jre_headless util-linux ];
  patches = [./opensearch-home-fix.patch ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -R bin config lib modules plugins $out

    substituteInPlace $out/bin/opensearch \
      --replace 'bin/opensearch-keystore' "$out/bin/opensearch-keystore"

    wrapProgram $out/bin/opensearch \
      --prefix PATH : "${lib.makeBinPath [ util-linux gnugrep coreutils ]}" \
      --set JAVA_HOME "${jre_headless}"

    wrapProgram $out/bin/opensearch-plugin --set JAVA_HOME "${jre_headless}"

    runHook postInstall
  '';

  passthru.tests = nixosTests.opensearch;

  meta = {
    description = "Open Source, Distributed, RESTful Search Engine";
    homepage = "https://github.com/opensearch-project/OpenSearch";
    license = lib.licenses.asl20;
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [ shyim ];
  };
}
