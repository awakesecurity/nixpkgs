{ system ? builtins.currentSystem
, config ? { }
, pkgs ? import ../.. { inherit system config; }
}:

let
  lib = pkgs.lib;

  inherit (import ../lib/testing-python.nix { inherit system pkgs; })
    makeTest;

  pgPackages = lib.sort (x: y: lib.versionOlder x.version y.version)
    (lib.attrValues (import ../../pkgs/servers/sql/postgresql pkgs));

  start = lib.head pgPackages;

  end = lib.last pgPackages;

  insert = pkgs.writeShellApplication {
    name = "insert";
    runtimeInputs = [ start pkgs.gnugrep ];
    text = ''
      run_sql() {
        su -c 'psql testdb -At -v ON_ERROR_STOP=1' postgres
      }

      run_sql <<- 'QUERY'
        CREATE TABLE books (
          title   text,
          author  text,
          year    int
        );

        INSERT INTO books (title, author, year) VALUES
        ('Do Androids Dream Of Electric Sheep?', 'Philip K. Dick', 1968),
        ('Neuromancer', 'William Gibson', 1984),
        ('Cryptonomicon', 'Neal Stephenson', 1999),
        ('Accelerando', 'Charles Stross', 2005);
      QUERY
    '';
  };

  verify = pkgs.writeShellApplication {
    name = "verify";
    runtimeInputs = [ end pkgs.gnugrep ];
    text = ''
      run_sql() {
        su -c 'psql testdb -At -v ON_ERROR_STOP=1' postgres
      }

      die() {
        echo "$1" >&2 && exit 1
      }

      run_sql <<- 'QUERY' | grep 't' || die 'No author found 1'
        SELECT exists(SELECT * FROM books WHERE author = 'Philip K. Dick');
      QUERY

      run_sql <<- 'QUERY' | grep 't' || die 'No title found'
        SELECT exists(SELECT * FROM books WHERE title = 'Neuromancer');
      QUERY

      run_sql <<- 'QUERY' | grep 't' || die 'No year found'
        SELECT exists(SELECT * FROM books WHERE year = 1999);
      QUERY

      run_sql <<- 'QUERY' | grep 't' || die 'No author found 2'
        SELECT exists(SELECT * FROM books WHERE author = 'Charles Stross');
      QUERY
    '';
  };

  dropLast = n: l:
    lib.reverseList (lib.drop n (lib.reverseList l));

  nodes = {
    start = {
      services.postgresql = {
        enable = true;

        package = start;

        dataDir = "/var/lib/postgresql/${start.psqlSchema}";

        ensureDatabases = [ "testdb" ];
      };
    };
    end = {
      services.postgresql = {
        enable = true;

        package = end;

        dataDir = "/var/lib/postgresql/${end.psqlSchema}";

        upgradeFrom = lib.forEach (dropLast 1 pgPackages) (package: {
          inherit package;

          dataDir = "/var/lib/postgresql/${package.psqlSchema}";
        });

        analyzeAfterUpgrade = true;
      };

      # We want the service to start after the data directory has been copied.
      systemd.services.postgresql.wantedBy = lib.mkForce [ ];
    };
  };
in
makeTest {
  name = "postgresql-upgrade";

  meta.maintainers = [ lib.maintainers.jsoo1 ];

  inherit nodes;

  testScript = ''
    import os
    import tempfile

    with tempfile.TemporaryDirectory(dir=os.getenv("out")) as tmp:
        start.wait_for_unit("postgresql.service")
        start.succeed("${insert}/bin/insert")
        start.succeed("systemctl stop postgresql.service")
        start.copy_from_vm(
          source="${nodes.start.services.postgresql.dataDir}",
          target_dir=tmp,
        )

        end.copy_from_host(
            source=tmp,
            target="${builtins.dirOf nodes.end.services.postgresql.dataDir}",
        )
        end.succeed("systemctl start postgresql.service")
        end.succeed("${verify}/bin/verify")

        end.succeed("systemctl restart postgresql.service")
        end.succeed("${verify}/bin/verify")
  '';
}
