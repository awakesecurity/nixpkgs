{ lib, buildPythonPackage, fetchPypi, pythonOlder
, coverage
, mock
, pytest
, pytestcov
, setuptools
}:

buildPythonPackage rec {
  pname = "gunicorn";
  version = "20.1.0";
  disabled = pythonOlder "3.5";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-4KlotboV+KMo/f16sfy1r0RwwoqvflXfAqmbwTE45ug=";
  };

  propagatedBuildInputs = [ setuptools ];

  checkInputs = [ pytest mock pytestcov coverage ];

  /*prePatch = ''
    substituteInPlace requirements_test.txt --replace "==" ">=" \
      --replace "coverage>=4.0,<4.4" "coverage"
  '';*/

  # better than no tests
  checkPhase = ''
    $out/bin/gunicorn --help > /dev/null
  '';

  pythonImportsCheck = [ "gunicorn" ];

  meta = with lib; {
    homepage = "https://github.com/benoitc/gunicorn";
    description = "WSGI HTTP Server for UNIX";
    license = licenses.mit;
  };
}
