{ src, mkYarnPackage }:

mkYarnPackage {
  name = "airflow-frontend";
  inherit src;
  packageJSON = ./package.json;
  yarnLock = ./yarn.lock;
  yarnNix = ./yarn.nix;
  doDist = false;

  configurePhase = ''
    cp -r $node_modules node_modules
  '';

  buildPhase = ''
    yarn --offline build
  '';

  installPhase = ''
    mkdir -p $out/static/
    cp -r static/dist $out/static
  '';
}
