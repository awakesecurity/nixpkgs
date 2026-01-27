{
  callPackage,
  staticCredentialsFile ? "/etc/nix-docker-credentials.txt",
}:
let
  generic-fetcher = callPackage ./generic-fetcher.nix { inherit staticCredentialsFile; };
in

args@{
  repository ? "library",
  imageName,
  tag,
  ...
}:

generic-fetcher (
  {
    fetcher = "hocker-config";
    name = "${repository}_${imageName}_${tag}-config.json";
    tag = "unused";
  }
  // args
)
