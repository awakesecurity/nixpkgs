{ lib
, buildPythonPackage
, fetchPypi
, pythonOlder
, pyjwt
, requests
, requests_toolbelt
, setuptools
}:

buildPythonPackage rec {
  pname = "python-arango";
  version = "7.5.3";
  disabled = pythonOlder "3.7";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0rgybg4jvqq3p52gv98pazalzhriczkdz9fhfvmgi978hl4vz2gl";
  };

  propagatedBuildInputs = [
    requests
    requests_toolbelt
    pyjwt
    setuptools
  ];

  postPatch = ''
    substituteInPlace setup.py --replace 'urllib3>=1.26.0' 'urllib3'
  '';

  meta = with lib; {
    description = "Python Driver for ArangoDB";
    homepage = "https://github.com/ArangoDB-Community/python-arango";
    license = licenses.mit;
    maintainers = [ maintainers.jsoo1 ];
  };
}
