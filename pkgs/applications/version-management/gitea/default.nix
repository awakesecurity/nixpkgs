{ lib
, buildGoPackage
, fetchurl
, fetchpatch
, makeWrapper
, git
, bash
, gzip
, openssh
, pam
, sqliteSupport ? true
, pamSupport ? true
, nixosTests
}:

buildGoPackage rec {
  pname = "gitea";
  version = "1.17.2";

  # not fetching directly from the git repo, because that lacks several vendor files for the web UI
  src = fetchurl {
    url = "https://github.com/go-gitea/gitea/releases/download/v${version}/gitea-src-${version}.tar.gz";
    sha256 = "sha256-pDg+HC3dbWf0RxoLvBtIOaFauP1pUYBOG+Q9cinh3lg=";
  };

  patches = [
    ./static-root-path.patch
    (fetchpatch {
      name = "CVE-2022-0905.patch";
      url = "https://github.com/go-gitea/gitea/commit/1314f38b59748397b3429fb9bc9f9d6bac85d2f2.patch";
      sha256 = "1hq16rmv69lp9w2qyrrhj04mmmqkdc361n2cls460pnzqk88wj0g";
    })
    (fetchpatch {
      name = "CVE-2022-1058.patch";
      url = "https://github.com/go-gitea/gitea/commit/e3d8e92bdc67562783de9a76b5b7842b68daeb48.patch";
      sha256 = "0vvaqqhmx3gkw8fa64ifk2x546zsvlmf65grk29lhzsw1y148sy9";
    })
  ];

  postPatch = ''
    substituteInPlace modules/setting/setting.go --subst-var data
  '';

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = lib.optional pamSupport pam;

  preBuild =
    let
      tags = lib.optional pamSupport "pam"
        ++ lib.optional sqliteSupport "sqlite sqlite_unlock_notify";
      tagsString = lib.concatStringsSep " " tags;
    in
    ''
      export buildFlagsArray=(
        -tags="${tagsString}"
        -ldflags='-X "main.Version=${version}" -X "main.Tags=${tagsString}"'
      )
    '';

  outputs = [ "out" "data" ];

  postInstall = ''
    mkdir $data
    cp -R ./go/src/${goPackagePath}/{public,templates,options} $data
    mkdir -p $out
    cp -R ./go/src/${goPackagePath}/options/locale $out/locale

    wrapProgram $out/bin/gitea \
      --prefix PATH : ${lib.makeBinPath [ bash git gzip openssh ]}
  '';

  goPackagePath = "code.gitea.io/gitea";

  passthru.tests.gitea = nixosTests.gitea;

  meta = with lib; {
    description = "Git with a cup of tea";
    homepage = "https://gitea.io";
    license = licenses.mit;
    maintainers = with maintainers; [ disassembler kolaente ma27 techknowlogick ];
  };
}
