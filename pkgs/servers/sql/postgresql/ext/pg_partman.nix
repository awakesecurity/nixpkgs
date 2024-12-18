{ lib, stdenv, fetchFromGitHub, postgresql, buildPostgresqlExtension }:

buildPostgresqlExtension rec {
  pname = "pg_partman";
  version = "4.7.4";

  src = fetchFromGitHub {
    owner  = "pgpartman";
    repo   = pname;
    rev    = "refs/tags/v${version}";
    sha256 = "sha256-DdE/hqCrju678Xk3xXGVFhKQM3x9skQQKolNJ2/3gbs=";
  };

  meta = with lib; {
    description = "Partition management extension for PostgreSQL";
    homepage    = "https://github.com/pgpartman/pg_partman";
    changelog   = "https://github.com/pgpartman/pg_partman/raw/v${version}/CHANGELOG.txt";
    maintainers = with maintainers; [ ggpeti ];
    platforms   = postgresql.meta.platforms;
    license     = licenses.postgresql;
    broken      = versionOlder postgresql.version "14";
  };
}
