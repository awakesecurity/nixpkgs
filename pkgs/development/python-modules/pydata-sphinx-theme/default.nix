{ lib
, buildPythonPackage
, pythonOlder
, fetchPypi
, sphinx
, accessible-pygments
, beautifulsoup4
, docutils
, packaging
}:

buildPythonPackage rec {
  pname = "pydata-sphinx-theme";
  version = "0.13.0";

  format = "wheel";

  disabled = pythonOlder "3.7";

  src = fetchPypi {
    inherit version format;
    dist = "py3";
    python = "py3";
    pname = "pydata_sphinx_theme";
    sha256 = "sha256-+ITUC7adMdlk/xnWBk97zqqmNBk1/bwJLVwknR/wC1I=";
  };

  propagatedBuildInputs = [
    sphinx
    accessible-pygments
    beautifulsoup4
    docutils
    packaging
  ];

  pythonImportsCheck = [
    "pydata_sphinx_theme"
  ];

  meta = with lib; {
    description = "Bootstrap-based Sphinx theme from the PyData community";
    homepage = "https://github.com/pydata/pydata-sphinx-theme";
    license = licenses.bsd3;
    maintainers = with maintainers; [ marsam ];
  };
}
