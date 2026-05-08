{ self, haskellNix, utils, nixpkgs, ... }@args:
utils.lib.eachDefaultSystem (system: {
  packages = import ./packages.nix system args;
})
