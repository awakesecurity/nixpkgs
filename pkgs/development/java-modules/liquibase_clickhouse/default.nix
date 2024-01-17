{ lib, stdenv, fetchMavenArtifact }:

stdenv.mkDerivation rec {
  pname = "liquibase-clickhouse";
  version = "0.7.3-awake";

  src = fetchMavenArtifact {
    artifactId = "liquibase-clickhouse";
    groupId = "com.mediarithmics";
    sha256 = "sha256-nTLOPAwKgbzmIAutMhHVpC8d6F0UvcLDa94mB2MJwAo=";
    classifier = "shaded";
    repos = [
      "http://jenkins.mv.awakenetworks.net:9081/content/repositories/thirdpartypatched/"
    ];
    inherit version;
  };

  installPhase = ''
    runHook preInstall
    install -m444 -D $src/share/java/*liquibase-clickhouse-${version}.jar $out/share/java/liquibase-clickhouse.jar
    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/MEDIARITHMICS/liquibase-clickhouse";
    description = "ClickHouse driver for Liquibase";
    license = licenses.asl20;
    platforms = platforms.unix;
  };
}
