{ lib
, rustPlatform
, fetchFromGitHub
, installShellFiles
, stdenv
, darwin
  # tests
, ruff-lsp
}:

rustPlatform.buildRustPackage rec {
  pname = "ruff";
  version = "0.1.4";

  src = fetchFromGitHub {
    owner = "astral-sh";
    repo = "ruff";
    rev = "refs/tags/v${version}";
    hash = "sha256-vdhyzFUimc9gBsLpk7WKwQQ0YtGJg3us+6JCFnXSMrI=";
  };

  cargoHash = "sha256-3p6X+EV4xQ+eh2ezPh5+cJxvoGErx0q2n5pESVf11Eg=";

  nativeBuildInputs = [
    installShellFiles
  ];

  buildInputs = lib.optionals stdenv.isDarwin [
    darwin.apple_sdk.frameworks.CoreServices
  ];

  cargoBuildFlags = [ "--package=ruff_cli" ];
  cargoTestFlags = cargoBuildFlags;

  preBuild = lib.optionalString (stdenv.isDarwin && stdenv.isx86_64) ''
    # See https://github.com/jemalloc/jemalloc/issues/1997
    # Using a value of 48 should work on both emulated and native x86_64-darwin.
    export JEMALLOC_SYS_WITH_LG_VADDR=48
  '';

  # tests expect no colors
  preCheck = ''
    export NO_COLOR=1
  '';

  postInstall = ''
    installShellCompletion --cmd ruff \
      --bash <($out/bin/ruff generate-shell-completion bash) \
      --fish <($out/bin/ruff generate-shell-completion fish) \
      --zsh <($out/bin/ruff generate-shell-completion zsh)
  '';

  passthru.tests = {
    inherit ruff-lsp;
  };

  meta = with lib; {
    description = "An extremely fast Python linter";
    homepage = "https://github.com/astral-sh/ruff";
    changelog = "https://github.com/astral-sh/ruff/releases/tag/v${version}";
    license = licenses.mit;
    mainProgram = "ruff";
    maintainers = with maintainers; [ figsoda ];
  };
}
