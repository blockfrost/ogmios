{ self, haskellNix, utils, nixpkgs, ... }@args:
utils.lib.eachDefaultSystem (system: rec {
  packages = import ./packages.nix system args;
  checks.unit = packages.unit-test;
})
