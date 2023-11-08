{ lib, stdenv, fetchzip }:

stdenv.mkDerivation rec {
  pname = "tfc-agent";
  version = "1.13.0";
  src = fetchzip {
    url = "https://releases.hashicorp.com/tfc-agent/${version}/tfc-agent_${version}_linux_amd64.zip";
    sha256 = "sha256-juhTmxf5+6pGare598HKu8ha5Mxs5RaGWQima/jpf2o=";
    stripRoot = false;
  };

  installPhase = ''
    mkdir $out
    install tfc-agent* $out/
  '';

  meta = {
    description = "Polling Terraform Cloud Agent";
    license = lib.licenses.unfree;
    homepage = "https://developer.hashicorp.com/terraform/cloud-docs/agents";
    sourceProvenance = [
      lib.sourceTypes.binaryNativeCode
    ];

    platforms = [
      "x86_64-linux"
    ];
  };
}
