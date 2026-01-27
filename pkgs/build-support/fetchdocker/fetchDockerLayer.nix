{
  callPackage,
  staticCredentialsFile ? "/etc/nix-docker-credentials.txt",
}:
let
  generic-fetcher = callPackage ./generic-fetcher.nix { inherit staticCredentialsFile; };
in

args@{ layerDigest, ... }:

generic-fetcher (
  {
    fetcher = "hocker-layer";
    name = "docker-layer-${layerDigest}.tar.gz";
    tag = "unused";
  }
  // args
)
