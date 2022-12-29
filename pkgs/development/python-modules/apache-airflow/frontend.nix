{ src, mkYarnPackage }:

mkYarnPackage {
  name = "airflow-frontend";
  inherit src;
  packageJSON = ./package.json;
  yarnLock = ./yarn.lock;
  yarnNix = ./yarn.nix;
  doDist = false;

  # The webpack license plugin tries to create /licenses when given the
  # original relative path
  postPatch = ''
    sed -i 's!../../../../licenses/LICENSES-ui.txt!licenses/LICENSES-ui.txt!' webpack.config.js
  '';

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
