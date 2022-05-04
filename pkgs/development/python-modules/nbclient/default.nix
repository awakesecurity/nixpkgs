{ lib, buildPythonPackage, fetchPypi, pythonOlder,
  async_generator, traitlets, nbformat, nest-asyncio, jupyter-client,
  pytest, xmltodict, nbconvert, ipywidgets
}:

buildPythonPackage rec {
  pname = "nbclient";
  version = "0.6.3";
  format = "setuptools";

  disabled = pythonOlder "3.7";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-uAcm/B+4mg6Pi+HnfijQAmsejtkLwUPIoMdiLk+M3Z4=";
  };

  doCheck = false; # Avoid infinite recursion
  checkInputs = [ pytest xmltodict nbconvert ipywidgets ];
  propagatedBuildInputs = [ async_generator traitlets nbformat nest-asyncio jupyter-client ];

  meta = with lib; {
    homepage = "https://github.com/jupyter/nbclient";
    description = "A client library for executing notebooks";
    license = licenses.bsd3;
    maintainers = [ maintainers.erictapen ];
  };
}
