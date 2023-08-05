{ lib, buildPythonPackage, fetchPypi, isPy27, flask, pytestCheckHook, pytest-cov, pytest-xprocess, pytestcache }:

buildPythonPackage rec {
  pname = "Flask-Caching";
  version = "1.10.1";
  disabled = isPy27; # invalid python2 syntax

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-zxm3IvzrwroD5K58VbUy7VPwy/aDzjb6/l6IF4mgHAA=";
  };

  propagatedBuildInputs = [ flask ];

  checkInputs = [ pytestCheckHook pytest-cov pytest-xprocess pytestcache ];

  disabledTests = [
    # backend_cache relies on pytest-cache, which is a stale package from 2013
    "backend_cache"
    # optional backends
    "Redis"
    "Memcache"
  ];

  meta = with lib; {
    description = "Adds caching support to your Flask application";
    homepage = "https://github.com/sh4nks/flask-caching";
    license = licenses.bsd3;
  };
}
