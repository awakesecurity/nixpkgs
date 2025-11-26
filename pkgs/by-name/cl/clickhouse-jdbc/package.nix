{ lib, stdenv, fetchMavenArtifact }:

stdenv.mkDerivation rec {
  pname = "clickhouse-jdbc";
  version = "0.8.6";

  src = fetchMavenArtifact {
    artifactId = "clickhouse-jdbc";
    groupId = "com.clickhouse";
    classifier = "shaded-all";
    sha256 = "sha256-/pYYrPFvUQX5HppevFPrlb8btmnz8gEYX8phEr1f1SU=";
    inherit version;
  };

  ## Use the `-all` jar to avoid having to fetch clickhouse-client (and perhaps other jars) as transitive dependencies.
  installPhase = ''
    runHook preInstall
    install -m444 -D $src/share/java/clickhouse-jdbc-${version}-shaded-all.jar $out/share/java/clickhouse-jdbc-shaded-all.jar
    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/ClickHouse/clickhouse-java/tree/main/clickhouse-jdbc";
    description = "JDBC driver for ClickHouse allowing Java programs to connect to a ClickHouse database";
    license = licenses.asl20;
    platforms = platforms.unix;
  };
}
