{ lib
, buildPythonPackage
, fetchPypi
, apispec_3
, colorama
, click
, email_validator
, flask
, flask-babel
, flask-jwt-extended_3
, flask-login_0_4
, flask-openid
, flask_sqlalchemy
, flask_wtf
, jsonschema
, marshmallow
, marshmallow-enum
, marshmallow-sqlalchemy
, python-dateutil
, prison
, pyjwt1
, pyyaml
, sqlalchemy-utils
}:

buildPythonPackage rec {
  pname = "flask-appbuilder";
  version = "3.4.5";

  src = fetchPypi {
    pname = "Flask-AppBuilder";
    inherit version;
    sha256 = "sha256-3lPl2iUKOmSGXuCi7S+SNRF9Aga/bzO9/j49pjNLsNE=";
  };

  propagatedBuildInputs = [
    apispec_3
    colorama
    click
    email_validator
    flask
    flask-babel
    flask-jwt-extended_3
    flask-login_0_4
    flask-openid
    flask_sqlalchemy
    flask_wtf
    jsonschema
    marshmallow
    marshmallow-enum
    marshmallow-sqlalchemy
    python-dateutil
    prison
    pyjwt1
    pyyaml
    sqlalchemy-utils
  ];

  # Majority of tests require network access or mongo
  doCheck = false;

  pythonImportsCheck = [ "flask_appbuilder" ];

  meta = with lib; {
    description = "Simple and rapid application development framework, built on top of Flask";
    homepage = "https://github.com/dpgaspar/flask-appbuilder/";
    license = licenses.bsd3;
    maintainers = with maintainers; [ costrouc ];
  };
}
