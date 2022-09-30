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
  version = "7.5.0";
  disabled = pythonOlder "3.7";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1qnvnyrb6djzq2hhr7473cbqj57cxkyyfc9qlv5rgc572fwh3nkd";
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
