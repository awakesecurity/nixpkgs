{ lib
, aiohttp
, buildPythonPackage
, fetchPypi
, pydantic
, pytestCheckHook
, pythonOlder
, websockets
}:

buildPythonPackage rec {
  pname = "aiolivisi";
  version = "0.0.16";
  format = "setuptools";

  disabled = pythonOlder "3.8";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-L7KeTdC3IPbXBLDkP86CyQ59s2bL4byxgKhl8YCmZHQ=";
  };

  postPatch = ''
    # https://github.com/StefanIacobLivisi/aiolivisi/pull/3
    substituteInPlace setup.py \
      --replace 'REQUIREMENTS = list(val.strip() for val in open("requirements.txt"))' "" \
      --replace "REQUIREMENTS," "[],"
  '';

  propagatedBuildInputs = [
    aiohttp
    pydantic
    websockets
  ];

  # Module has no tests
  doCheck = false;

  pythonImportsCheck = [
    "aiolivisi"
  ];

  meta = with lib; {
    description = "Module to communicate with LIVISI Smart Home Controller";
    homepage = "https://github.com/StefanIacobLivisi/aiolivisi";
    changelog = "https://github.com/StefanIacobLivisi/aiolivisi/releases/tag/${version}";
    license = with licenses; [ asl20 ];
    maintainers = with maintainers; [ fab ];
  };
}
