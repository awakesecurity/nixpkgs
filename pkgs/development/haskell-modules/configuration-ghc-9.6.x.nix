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
  ghc-lib-parser-ex = doDistribute self.ghc-lib-parser-ex_9_6_0_0;

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
}
