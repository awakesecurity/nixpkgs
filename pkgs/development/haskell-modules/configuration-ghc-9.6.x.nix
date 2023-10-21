{ pkgs, haskellLib }:

let
  inherit (pkgs) lib;
in

with haskellLib;

self: super: {
  llvmPackages = lib.dontRecurseIntoAttrs self.ghc.llvmPackages;

  # Disable GHC core libraries
  array = null;
  base = null;
  binary = null;
  bytestring = null;
  Cabal = null;
  Cabal-syntax = null;
  containers = null;
  deepseq = null;
  directory = null;
  exceptions = null;
  filepath = null;
  ghc-bignum = null;
  ghc-boot = null;
  ghc-boot-th = null;
  ghc-compact = null;
  ghc-heap = null;
  ghc-prim = null;
  ghci = null;
  haskeline = null;
  hpc = null;
  integer-gmp = null;
  libiserv = null;
  mtl = null;
  parsec = null;
  pretty = null;
  process = null;
  rts = null;
  stm = null;
  system-cxx-std-lib = null;
  template-haskell = null;
  # terminfo is not built if GHC is a cross compiler
  terminfo = if pkgs.stdenv.hostPlatform == pkgs.stdenv.buildPlatform then null else self.terminfo_0_4_1_5;
  text = null;
  time = null;
  transformers = null;
  unix = null;
  xhtml = null;

  th-desugar = doDistribute self.th-desugar_1_15;
  th-abstraction = doDistribute self.th-abstraction_0_5_0_0;
  tagged = doDistribute self.tagged_0_8_7; # allows template-haskell-2.20
  primitive = doDistribute (dontCheck self.primitive_0_7_4_0); # allows base >= 4.18
  indexed-traversable = doDistribute super.indexed-traversable_0_1_2_1; # allows base >= 4.18
  OneTuple = doDistribute (dontCheck super.OneTuple_0_4_1_1); # allows base >= 4.18
  inspection-testing = doDistribute self.inspection-testing_0_5_0_1; # allows base >= 4.18
  tasty-inspection-testing = doDistribute self.tasty-inspection-testing_0_2;
  # Too strict bounds on ghc-prim and template-haskell
  aeson = doDistribute (doJailbreak self.aeson_2_1_2_1);
  turtle = doDistribute self.turtle_1_6_1;
  memory = doDistribute self.memory_0_18_0;
  semigroupoids = doDistribute self.semigroupoids_6_0_0_1;
  bifunctors = doDistribute self.bifunctors_5_6_1;
  cabal-plan = doDistribute self.cabal-plan_0_7_3_0;
  base-compat = doDistribute self.base-compat_0_13_0;
  base-compat-batteries = doDistribute self.base-compat-batteries_0_13_0;
  semialign = doDistribute self.semialign_1_3;
  assoc = doDistribute self.assoc_1_1;
  strict = doDistribute self.strict_0_5;

  # Too strict upper bound on template-haskell
  # https://github.com/mokus0/th-extras/pull/21
  th-extras = doJailbreak super.th-extras;

  ghc-lib = doDistribute self.ghc-lib_9_6_2_20230523;
  ghc-lib-parser = doDistribute self.ghc-lib-parser_9_6_2_20230523;
  ghc-lib-parser-ex = doDistribute self.ghc-lib-parser-ex_9_6_0_2;

  # Tests fail due to the newly-build fourmolu not being in PATH
  # https://github.com/fourmolu/fourmolu/issues/231
  fourmolu = dontCheck super.fourmolu_0_14_0_0;
  ormolu = self.generateOptparseApplicativeCompletions [ "ormolu" ] (enableSeparateBinOutput super.ormolu_0_7_2_0);
  hlint = super.hlint_3_6_1;

  # v0.1.6 forbids base >= 4.18
  singleton-bool = doDistribute super.singleton-bool_0_1_7;

  #
  # Too strict bounds without upstream fix
  #

  # Forbids transformers >= 0.6
  quickcheck-classes-base = doJailbreak super.quickcheck-classes-base;
  # Forbids base >= 4.18
  singleton-bool = doJailbreak super.singleton-bool;
  # Forbids base >= 4.18
  unliftio-core = doJailbreak super.unliftio-core;
  # Forbids mtl >= 2.3
  ChasingBottoms = doJailbreak super.ChasingBottoms;
  # Forbids base >= 4.18
  cabal-install-solver = doJailbreak super.cabal-install-solver;
  cabal-install = doJailbreak super.cabal-install;
  # Forbids base >= 4.18
  lukko = doJailbreak super.lukko;

  #
  # Too strict bounds, waiting on Hackage release in nixpkgs
  #

  # base >= 4.18 is allowed in those newer versions
  boring = assert !(self ? boring_0_2_1); doJailbreak super.boring;
  some = assert !(self ? some_1_0_5); doJailbreak super.some;
  these = assert !(self ? assoc_1_2); doJailbreak super.these;
  # Temporarily upgrade manually until the attribute is available
  doctest = doDistribute (overrideCabal {
    version = "0.21.1";
    sha256 = "0vgl89p6iaj2mwnd1gkpq86q1g18shdcws0p3can25algi2sldk3";
  } super.doctest_0_21_0);

  #
  # Too strict bounds, waiting on Revision in nixpkgs
  #

  # Revision 7 lifts the offending bound on ghc-prim
  ed25519 = jailbreakWhileRevision 6 super.ed25519;
  # Revision 6 lifts the offending bound on base
  tar = jailbreakWhileRevision 5 super.tar;
  # Revision 2 lifts the offending bound on base
  HTTP = jailbreakWhileRevision 1 super.HTTP;
  # Revision 1 lifts the offending bound on base
  dec = jailbreakWhileRevision 0 super.dec;
  # Revision 2 lifts the offending bound on base
  cryptohash-sha256 = jailbreakWhileRevision 1 super.cryptohash-sha256;
  # Revision 4 lifts offending template-haskell bound
  uuid-types = jailbreakWhileRevision 3 super.uuid-types;
  # Revision 1 lifts offending base bound
  quickcheck-instances = jailbreakWhileRevision 0 super.quickcheck-instances;
  # Revision 1 lifts offending base bound
  generically = jailbreakWhileRevision 0 super.generically;
  # Revision 3 lifts offending template-haskell bound
  hackage-security = jailbreakWhileRevision 2 super.hackage-security;

  #
  # Compilation failure workarounds
  #

  # Test suite doesn't compile with base-4.18 / GHC 9.6
  # https://github.com/dreixel/syb/issues/40
  syb = dontCheck super.syb;

  # Support for template-haskell >= 2.16
  language-haskell-extract = appendPatch (pkgs.fetchpatch {
    url = "https://gitlab.haskell.org/ghc/head.hackage/-/raw/dfd024c9a336c752288ec35879017a43bd7e85a0/patches/language-haskell-extract-0.2.4.patch";
    sha256 = "0w4y3v69nd3yafpml4gr23l94bdhbmx8xky48a59lckmz5x9fgxv";
  }) (doJailbreak super.language-haskell-extract);

  # Patch for support of mtl-2.3
  monad-par = appendPatch
    (pkgs.fetchpatch {
      name = "monad-par-mtl-2.3.patch";
      url = "https://github.com/simonmar/monad-par/pull/75/commits/ce53f6c1f8246224bfe0223f4aa3d077b7b6cc6c.patch";
      sha256 = "1jxkl3b3lkjhk83f5q220nmjxbkmni0jswivdw4wfbzp571djrlx";
      stripLen = 1;
    })
    (doJailbreak super.monad-par);

  # Patch 0.17.1 for support of mtl-2.3
  xmonad-contrib = appendPatch
    (pkgs.fetchpatch {
      name = "xmonad-contrib-mtl-2.3.patch";
      url = "https://github.com/xmonad/xmonad-contrib/commit/8cb789af39e93edb07f1eee39c87908e0d7c5ee5.patch";
      sha256 = "sha256-ehCvVy0N2Udii/0K79dsRSBP7/i84yMoeyupvO8WQz4=";
    })
    (doJailbreak super.xmonad-contrib);

  # Patch 0.12.0.1 for support of unix-2.8.0.0
  arbtt = appendPatch
    (pkgs.fetchpatch {
      name = "arbtt-unix-2.8.0.0.patch";
      url = "https://github.com/nomeata/arbtt/pull/168/commits/ddaac94395ac50e3d3cd34c133dda4a8e5a3fd6c.patch";
      sha256 = "sha256-5Gmz23f4M+NfgduA5O+9RaPmnneAB/lAlge8MrFpJYs=";
    })
    super.arbtt;

  # 2023-04-03: plugins disabled for hls 1.10.0.0 based on
  #
  haskell-language-server =
    let
      # TODO: HLS-2.0.0.0 added support for the foumolu plugin for ghc-9.6.
      # However, putting together all the overrides to get the latest
      # version of fourmolu compiling together with ghc-9.6 and HLS is a
      # little annoying, so currently fourmolu has been disabled.  We should
      # try to enable this at some point in the future.
      hlsWithFlags = disableCabalFlag "fourmolu" super.haskell-language-server;
    in
    hlsWithFlags.override {
      hls-ormolu-plugin = null;
      hls-floskell-plugin = null;
      hls-fourmolu-plugin = null;
      hls-hlint-plugin = null;
      hls-stylish-haskell-plugin = null;
    };

  # Newer version of servant required for GHC 9.6
  servant = self.servant_0_20;
  servant-server = self.servant-server_0_20;
  servant-client = self.servant-client_0_20;
  servant-client-core = self.servant-client-core_0_20;
  # Select versions compatible with servant_0_20
  servant-docs = self.servant-docs_0_13;
  servant-swagger = self.servant-swagger_1_2;
  # Jailbreaks for servant <0.20
  servant-lucid = doJailbreak super.servant-lucid;

  # Jailbreak strict upper bounds: http-api-data <0.6
  servant_0_20 = doJailbreak super.servant_0_20;
  servant-server_0_20 = doJailbreak super.servant-server_0_20;
  servant-client_0_20 = doJailbreak super.servant-client_0_20;
  servant-client-core_0_20 = doJailbreak super.servant-client-core_0_20;
  # Jailbreak strict upper bounds: doctest <0.22
  servant-swagger_1_2 = doJailbreak super.servant-swagger_1_2;

  lifted-base = dontCheck super.lifted-base;
  hw-fingertree = dontCheck super.hw-fingertree;
  hw-prim = dontCheck (doJailbreak super.hw-prim);
  stm-containers = dontCheck super.stm-containers;
  regex-tdfa = dontCheck super.regex-tdfa;
  rebase = doJailbreak super.rebase_1_20;
  rerebase = doJailbreak super.rerebase_1_20;
  hiedb = dontCheck super.hiedb;
  retrie = dontCheck super.retrie;
  # https://github.com/kowainik/relude/issues/436
  relude = dontCheck (doJailbreak super.relude);

  ghc-exactprint = unmarkBroken (addBuildDepends (with self.ghc-exactprint.scope; [
   HUnit Diff data-default extra fail free ghc-paths ordered-containers silently syb
  ]) super.ghc-exactprint_1_7_0_1);

  inherit (pkgs.lib.mapAttrs (_: doJailbreak ) super)
    hls-cabal-plugin
    algebraic-graphs
    co-log-core
    lens
    cryptohash-sha1
    cryptohash-md5
    ghc-trace-events
    tasty-hspec
    constraints-extras
    tree-diff
    implicit-hie-cradle
    focus
    hie-compat
    dbus       # template-haskell >=2.18 && <2.20, transformers <0.6, unix <2.8
    gi-cairo-connector          # mtl <2.3
    haskintex                   # text <2
    lens-family-th              # template-haskell <2.19
    ghc-prof                    # base <4.18
    profiteur                   # vector <0.13
    mfsolve                     # mtl <2.3
    cubicbezier                 # mtl <2.3
    dhall                       # template-haskell <2.20
    env-guard                   # doctest <0.21
    package-version             # doctest <0.21, tasty-hedgehog <1.4
  ;

  # Avoid triggering an issue in ghc-9.6.2
  gi-gtk = disableParallelBuilding super.gi-gtk;

  # Pending text-2.0 support https://github.com/gtk2hs/gtk2hs/issues/327
  gtk = doJailbreak super.gtk;

  # Doctest comments have bogus imports.
  bsb-http-chunked = dontCheck super.bsb-http-chunked;

  # Fix ghc-9.6.x build errors.
  libmpd = appendPatch
    (pkgs.fetchpatch { url = "https://github.com/vimus/libmpd-haskell/pull/138.patch";
                       sha256 = "sha256-CvvylXyRmoCoRJP2MzRwL0SBbrEzDGqAjXS+4LsLutQ=";
                     })
    super.libmpd;

  # Apply patch from PR with mtl-2.3 fix.
  ConfigFile = overrideCabal (drv: {
    editedCabalFile = null;
    buildDepends = drv.buildDepends or [] ++ [ self.HUnit ];
    patches = [(pkgs.fetchpatch {
      name = "ConfigFile-pr-12.patch";
      url = "https://github.com/jgoerzen/configfile/pull/12.patch";
      sha256 = "sha256-b7u9GiIAd2xpOrM0MfILHNb6Nt7070lNRIadn2l3DfQ=";
    })];
  }) super.ConfigFile;

  # The curl executable is required for withApplication tests.
  warp_3_3_28 = addTestToolDepend pkgs.curl super.warp_3_3_28;
}
