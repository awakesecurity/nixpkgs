{ lib
, stdenv
, fetchFromGitHub
, fetchpatch
, buildPythonPackage
, mypy-extensions
, python
, pythonOlder
, typed-ast
, typing-extensions
, tomli
, types-typed-ast
}:

buildPythonPackage rec {
  pname = "mypy";
  version = "unstable-2021-11-14";
  disabled = pythonOlder "3.6";

  src = fetchFromGitHub {
    owner = "python";
    repo = "mypy";
    rev = "053a1beb94ee4e5b3260725594315d1b6776e42f";
    sha256 = "sha256-q2ntj3y3GgXrw4v+yMvcqWFv4y/6YwunIj3bNzU9CH0=";
  };

  # remove pin with mypy>=0.920
  postPatch = ''
    substituteInPlace setup.py \
      --replace "typed_ast >= 1.4.0, < 1.5.0" "typed_ast >= 1.4.0, < 2"
  '';

  propagatedBuildInputs = [ typed-ast psutil mypy-extensions typing-extensions ];

  # Tests not included in pip package.
  doCheck = false;

  pythonImportsCheck = [
    "mypy"
    "mypy.api"
    "mypy.fastparse"
    "mypy.report"
    "mypy.types"
    "mypyc"
    "mypyc.analysis"
  ];

  # Compile mypy with mypyc, which makes mypy about 4 times faster. The compiled
  # version is also the default in the wheels on Pypi that include binaries.
  # is64bit: unfortunately the build would exhaust all possible memory on i686-linux.
  MYPY_USE_MYPYC = stdenv.buildPlatform.is64bit;

  # when testing reduce optimisation level to drastically reduce build time
  MYPYC_OPT_LEVEL = 1;

  meta = with lib; {
    description = "Optional static typing for Python";
    homepage = "http://www.mypy-lang.org";
    license = licenses.mit;
    maintainers = with maintainers; [ martingms lnl7 SuperSandro2000 ];
  };
}
