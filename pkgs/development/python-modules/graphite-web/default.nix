{
  lib,
  buildPythonPackage,
  python,
  cairocffi,
  django,
  django-tagging,
  fetchFromGitHub,
  gunicorn,
  mock,
  pyparsing,
  python-memcached,
  pythonOlder,
  pytz,
  six,
  txamqp,
  urllib3,
  whisper,
  nixosTests,
}:

buildPythonPackage rec {
  pname = "graphite-web";
  version = "unstable-2025-03-03";
  format = "setuptools";

  disabled = pythonOlder "3.7";

  src = fetchFromGitHub {
    owner = "graphite-project";
    repo = pname;
    rev = "49c28e2015d605ad9ec93524f7076dd924a4731a";
    hash = "sha256-TxsQPhnI5WhQvKKkDEYZ8xnyg/qf+N9Icej6d6A0jC0=";
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

  pythonImportsCheck = [ "graphite" ];

  passthru.tests = {
    inherit (nixosTests) graphite;
  };

  meta = with lib; {
    description = "Enterprise scalable realtime graphing";
    homepage = "http://graphiteapp.org/";
    license = licenses.asl20;
    maintainers = with maintainers; [
      offline
      basvandijk
    ];
  };
}
