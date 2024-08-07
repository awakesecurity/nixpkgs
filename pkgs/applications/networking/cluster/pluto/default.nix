{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "pluto";
  version = "5.18.1";

  src = fetchFromGitHub {
    owner = "FairwindsOps";
    repo = "pluto";
    rev = "v${version}";
    sha256 = "sha256-E4DPJDBa/WX5JVsWgqdEv/O/XCvHDLyaL+nSMmw6Npg=";
  };

  vendorHash = "sha256-okqDtxSKVLlmnm5JdCKSvRZkXTsghi/L5R9TX10WWjY=";

  ldflags = [
    "-w" "-s"
    "-X main.version=v${version}"
  ];

  meta = with lib; {
    homepage = "https://github.com/FairwindsOps/pluto";
    description = "Find deprecated Kubernetes apiVersions";
    license = licenses.asl20;
    maintainers = with maintainers; [ peterromfeldhk ];
  };
}
