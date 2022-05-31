{ lib
, buildPythonPackage
, fetchPypi
, marshmallow
, mock
, openapi-spec-validator
, prance
, pytestCheckHook
, pythonOlder
, pyyaml
}:

buildPythonPackage rec {
  pname = "apispec";
  version = "3.3.2";
  format = "setuptools";

  disabled = pythonOlder "3.5";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-0j69W3HlQeAxsCoZ2xC15tXvhFLFUoM+Phr8g2tAsa0=";
  };

  propagatedBuildInputs = [
    pyyaml
    prance
  ];

  checkInputs = [
    openapi-spec-validator
    marshmallow
    mock
    pytestCheckHook
  ];

  pythonImportsCheck = [
    "apispec"
  ];

  meta = with lib; {
    description = "A pluggable API specification generator with support for the OpenAPI Specification";
    homepage = "https://github.com/marshmallow-code/apispec";
    license = licenses.mit;
    maintainers = with maintainers; [ costrouc ];
  };
}
