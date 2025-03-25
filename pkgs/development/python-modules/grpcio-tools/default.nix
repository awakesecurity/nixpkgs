{
  lib,
  buildPythonPackage,
  fetchPypi,
  protobuf,
  grpcio,
  setuptools,
}:

buildPythonPackage rec {
  pname = "grpcio-tools";
  version = "1.64.1";
  pyproject = true;

  src = fetchPypi {
    pname = "grpcio_tools";
    inherit version;
    hash = "sha256-crNVC5GtuDVGVuzw9tHUYRKZBEuuEfsefMHRu2a4wes=";
  };

  outputs = [
    "out"
    "dev"
  ];

  enableParallelBuilding = true;

  build-system = [ setuptools ];

  pythonRelaxDeps = [
    "protobuf"
    "grpcio"
  ];

  dependencies = [
    protobuf
    grpcio
    setuptools
  ];

  # no tests in the package
  doCheck = false;

  pythonImportsCheck = [ "grpc_tools" ];

  meta = with lib; {
    description = "Protobuf code generator for gRPC";
    license = licenses.asl20;
    homepage = "https://grpc.io/grpc/python/";
    maintainers = [ ];
  };
}
