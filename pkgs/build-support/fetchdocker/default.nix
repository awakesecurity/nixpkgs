{
  stdenv,
  lib,
  coreutils,
  bash,
  gnutar,
  writeText,
}:
let
  stripScheme = builtins.replaceStrings [ "https://" "http://" ] [ "" "" ];
  stripNixStore = s: lib.removePrefix "${builtins.storeDir}/" s;
in
{
  name,
  registry ? "https://registry-1.docker.io/v2/",
  repository ? "library",
  imageName,
  tag,
  imageLayers,
  imageConfig,
  image ? "${stripScheme registry}/${repository}/${imageName}:${tag}",
}:

let
  # Abuse paths to collapse possible double slashes
  repoTag0 = toString (/. + "/${stripScheme registry}/${repository}/${imageName}");
  repoTag1 = lib.removePrefix "/" repoTag0;

  layers = map stripNixStore imageLayers;

  manifest = writeText "manifest.json" (
    builtins.toJSON [
      {
        Config = stripNixStore imageConfig;
        Layers = layers;
        RepoTags = [ "${repoTag1}:${tag}" ];
      }
    ]
  );

  repositories = writeText "repositories" (
    builtins.toJSON {
      ${repoTag1} = {
        ${tag} = lib.last layers;
      };
    }
  );

  imageFileStorePaths = writeText "imageFileStorePaths.txt" (
    lib.concatStringsSep "\n" ((lib.unique imageLayers) ++ [ imageConfig ])
  );
in
stdenv.mkDerivation {
  builder = ./fetchdocker-builder.sh;
  buildInputs = [ coreutils ];
  preferLocalBuild = true;

  inherit
    name
    imageName
    repository
    tag
    ;
  inherit
    bash
    gnutar
    manifest
    repositories
    ;
  inherit imageFileStorePaths;

  passthru = {
    inherit image;
  };
}
