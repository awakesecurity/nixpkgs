{ lib
, buildPythonPackage
, fetchPypi
, fetchurl
, fetchFromGitHub
, flake8
, pep8
, pep8-naming
, python-dateutil
, pytest
, pytz
, natsort
, tzlocal
}:

buildPythonPackage rec {
  pname = "cron-descriptor";
  version = "1.2.24";

  src = fetchFromGitHub rec {
    owner = "Salamek";
    repo = "cron-descriptor";
    rev = version;
    sha256 = "sha256-Gf7n8OiFuaN+8MqsXSg9RBPh2gXfPgjJ4xeuinGYKMw=";
  };

  checkInputs = [
    flake8
    pep8
    pep8-naming
    pytest
  ];

  checkPhase = ''
    python setup.py test
  '';

  meta = with lib; {
    description = "A Python library that converts cron expressions into human readable strings.";
    homepage = "https://github.com/Salamek/cron-descriptor";
    license = licenses.mit;
    maintainers = [ ];
  };
}
