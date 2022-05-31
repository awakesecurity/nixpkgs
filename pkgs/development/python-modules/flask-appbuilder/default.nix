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

  # See here: https://github.com/dpgaspar/Flask-AppBuilder/commit/7097a7b133f27c78d2b54d2a46e4a4c24478a066.patch
  #           https://github.com/dpgaspar/Flask-AppBuilder/pull/1610
  # The patch from the PR doesn't apply cleanly so I edited it manually.
  #patches = [ ./upgrade-to-flask_jwt_extended-4.patch ];

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

  /*
        "apispec[yaml]>=3.3, <4",
        "colorama>=0.3.9, <1",
        "click>=6.7, <9",
        "email_validator>=1.0.5, <2",
        "Flask>=0.12, <2",
        "Flask-Babel>=1, <3",
        "Flask-Login>=0.3, <0.5",
        "Flask-OpenID>=1.2.5, <2",
        "Flask-SQLAlchemy>=2.4, <3",
        "Flask-WTF>=0.14.2, <0.15.0",
        "Flask-JWT-Extended>=3.18, <4",
        "jsonschema>=3, <5",
        "marshmallow>=3, <4",
        "marshmallow-enum>=1.5.1, <2",
        "marshmallow-sqlalchemy>=0.22.0, <0.27.0",
        "python-dateutil>=2.3, <3",
        "prison>=0.2.1, <1.0.0",
        "PyJWT>=1.7.1, <2.0.0",
        # Cautious cap
        "SQLAlchemy<1.5",
        "sqlalchemy-utils>=0.32.21, <1",
        "WTForms<3.0.0",
  */

  /*postPatch = ''
    substituteInPlace setup.py \
      --replace "apispec[yaml]>=3.3, <4" "apispec[yaml] >=3.3" \
      --replace "Flask>=0.12, <2" "Flask" \
      --replace "Flask-Login>=0.3, <0.5" "Flask-Login >=0.3, <0.6" \
      --replace "Flask-Babel>=1, <2" "Flask-Babel >=1, <3" \
      --replace "Flask-WTF>=0.14.2, <0.15.0" "Flask-WTF" \
      --replace "marshmallow-sqlalchemy>=0.22.0, <0.24.0" "marshmallow-sqlalchemy" \
      --replace "Flask-JWT-Extended>=3.18, <4" "Flask-JWT-Extended>=4.1.0" \
      --replace "PyJWT>=1.7.1, <2.0.0" "PyJWT>=2.0.1" \
      --replace "prison>=0.2.1, <1.0.0" "prison" \
      --replace "SQLAlchemy<1.4.0" "SQLAlchemy"
  '';*/

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
