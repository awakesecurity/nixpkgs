{ lib
, buildPythonPackage
, fetchFromGitHub
, six
, nose
}:

buildPythonPackage rec {
  pname = "prison";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "betodealmeida";
    repo = "python-rison";
    rev = "4386bdf56afad70dec8bba6c63095fdee4384f6a";
    sha256 = "sha256-aCQ2254appVBsKuJgSeraWWyh1d9rt8KDt/f8afpVwo=";
  };

  propagatedBuildInputs = [
    six
  ];

  checkInputs = [
    nose
  ];

  meta = with lib; {
    description = "Rison encoder/decoder";
    homepage = "https://github.com/betodealmeida/python-rison";
    license = licenses.mit;
    maintainers = [ maintainers.costrouc ];
  };
}
