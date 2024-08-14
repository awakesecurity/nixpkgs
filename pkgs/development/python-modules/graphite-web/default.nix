{ lib
, stdenv
, buildPythonPackage
, python
, cairocffi
, django
, django-tagging
, fetchFromGitHub
, gunicorn
, mock
, pyparsing
, python-memcached
, pythonOlder
, pytz
, six
, txamqp
, urllib3
, whisper
}:

buildPythonPackage rec {
  pname = "graphite-web";
  version = "unstable-2024-07-30";
  format = "setuptools";

  disabled = pythonOlder "3.7";

  src = fetchFromGitHub {
    owner = "graphite-project";
    repo = pname;
    rev = "80c999a14b7f8c9e8141270a7e56682632b9161f";
    hash = "sha256-WjiC8aH9nGWDy8OINPGpAQ8cbHgT+bJgOUzIEq93hys=";
  };

  propagatedBuildInputs = [
    cairocffi
    django
    django-tagging
    gunicorn
    pyparsing
    python-memcached
    pytz
    six
    txamqp
    urllib3
    whisper
  ];

  postPatch = ''
    substituteInPlace setup.py \
      --replace "Django>=1.8,<3.1" "Django" \
      --replace "django-tagging==0.4.3" "django-tagging"
  '';

  # Carbon-s default installation is /opt/graphite. This env variable ensures
  # carbon is installed as a regular Python module.
  GRAPHITE_NO_PREFIX = "True";

  preConfigure = ''
    substituteInPlace webapp/graphite/settings.py \
      --replace "join(WEBAPP_DIR, 'content')" "join('$out', 'webapp', 'content')"
    
    # Django 4 defaults to datetime.tzinfo and it fails on:
    # AttributeError: 'zoneinfo.ZoneInfo' object has no attribute 'localize'
    echo "USE_DEPRECATED_PYTZ = True" >>webapp/graphite/settings.py
  '';

  checkInputs = [ mock ];
  checkPhase = ''
    runHook preCheck

    pushd webapp/
    # avoid confusion with installed module
    rm -r graphite
    # redis not practical in test environment
    substituteInPlace tests/test_tags.py \
      --replace test_redis_tagdb _dont_test_redis_tagdb
    # No rrdtool package in nixpkgs
    rm tests/test_readers_rrd.py

    DJANGO_SETTINGS_MODULE=tests.settings ${python.interpreter} manage.py test
    popd

    runHook postCheck
  '';

  pythonImportsCheck = [
    "graphite"
  ];

  meta = with lib; {
    description = "Enterprise scalable realtime graphing";
    homepage = "http://graphiteapp.org/";
    license = licenses.asl20;
    maintainers = with maintainers; [ offline basvandijk ];
  };
}
