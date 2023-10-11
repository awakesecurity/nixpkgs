{ lib
, buildPythonPackage
, fetchFromGitHub
, poetry-core
, pyrate-limiter
, requests
, pytestCheckHook
, requests-mock
}:

buildPythonPackage rec {
  pname = "requests-ratelimiter";
  version = "0.4.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "JWCook";
    repo = "requests-ratelimiter";
    rev = "v${version}";
    hash = "sha256-w4cBQRpk9UTuGA0lPDsqpQ3UEIQdYe38NYXz+V4+Lvc=";
  };

  preBuild = ''
    echo "from setuptools import setup;setup()" > setup.py
  '';

  nativeBuildInputs = [
    poetry-core
  ];

  propagatedBuildInputs = [
    pyrate-limiter
    requests
  ];

  checkInputs = [
    pytestCheckHook
    requests-mock
  ];

  pythonImportsCheck = [ "requests_ratelimiter" ];

  meta = with lib; {
    description = "Easy rate-limiting for python requests";
    homepage = "https://github.com/JWCook/requests-ratelimiter";
    changelog = "https://github.com/JWCook/requests-ratelimiter/blob/${src.rev}/HISTORY.md";
    license = licenses.mit;
    maintainers = with maintainers; [ mbalatsko ];
  };
}
