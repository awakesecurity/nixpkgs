{ lib
, blinker
, buildPythonPackage
, fetchPypi
, flask
, nose
, pythonAtLeast
, pythonOlder
, semantic-version
, werkzeug
}:

buildPythonPackage rec {
  pname = "flask-login";
  version = "0.4.1";
  format = "setuptools";

  disabled = pythonOlder "3.6";

  src = fetchPypi {
    pname = "Flask-Login";
    inherit version;
    sha256 = "sha256-yBXBrHs+NeIIFoXjiaZl8sdNfgd8uTzsq66jUtpHUuw=";
  };

  propagatedBuildInputs = [
    flask
    werkzeug
  ];

  checkInputs = [
    blinker
    nose
    semantic-version
  ];

  checkPhase = "nosetests -d";

  pythonImportsCheck = [
    "flask_login"
  ];

  meta = with lib; {
    description = "User session management for Flask";
    homepage = "https://github.com/maxcountryman/flask-login";
    license = licenses.mit;
    maintainers = with maintainers; [ abbradar ];
  };
}
