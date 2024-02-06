{ lib, stdenv, fetchFromGitHub, cmake, pkg-config, curl, postgresql, libuuid, libossp_uuid }:

stdenv.mkDerivation rec {
  pname = "clickhouse_fdw";
  version = "1.4.0";

  nativeBuildInputs = [ cmake pkg-config ];
  buildInputs = [ postgresql curl libuuid ]
    ++ lib.optional stdenv.isDarwin libossp_uuid;

  src = fetchFromGitHub {
    owner  = "ildus";
    repo   = pname;
    rev    = "refs/tags/${version}";
    sha256 = "sha256-ZjpMS3sgL0LjQI50OOHGotzfMVpWpJCCt4xYLmJhh+g=";
  };

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace 'find_program(PG_REGRESS NAMES pg_regress PATHS ''${PGSQL_PKGLIBDIR}/pgxs/src/test/regress/ REQUIRED)' 'set(PG_REGRESS ${postgresql}/lib/pgxs/src/test/regress/pg_regress)'
    
    substituteInPlace src/CMakeLists.txt \
      --replace 'DESTINATION ''${PGSQL_PKGLIBDIR}' "DESTINATION \"$out/lib\"" \
      --replace 'DESTINATION "''${PGSQL_SHAREDIR}/extension"' "DESTINATION \"$out/share/postgresql/extension\""
  '' + lib.optionalString stdenv.isDarwin ''
    substituteInPlace src/clickhouse-cpp/clickhouse/CMakeLists.txt \
      --replace 'TARGET_LINK_LIBRARIES (clickhouse-cpp-lib gcc_s)' "" \
      --replace 'TARGET_LINK_LIBRARIES (clickhouse-cpp-lib-static gcc_s)' ""
  '';

  meta = with lib; {
    broken      = versionOlder postgresql.version "11";
    description = "ClickHouse FDW for PostgreSQL";
    homepage    = "https://github.com/ildus/clickhouse_fdw";
    maintainers = with maintainers; [ ];
    platforms   = postgresql.meta.platforms;
    license     = licenses.asl20;
  };
}
