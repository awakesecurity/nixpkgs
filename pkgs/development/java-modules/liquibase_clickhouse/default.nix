{ lib, stdenv, fetchMavenArtifact }:

stdenv.mkDerivation rec {
  pname = "liquibase-clickhouse";
  version = "0.7.3-awake";

  src = fetchMavenArtifact {
    artifactId = "liquibase-clickhouse";
    groupId = "com.mediarithmics";
    sha256 = "sha256-Fm/n2uP5zlwWev5762/0yd/muaTtpcEAXoYJ7ZhHQaA=";
    classifier = "shaded";
    repos = [
      "https://artifactory.infra.corp.arista.io/artifactory/awake-ndr-third-party-patched/"
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
