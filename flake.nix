{
  nixConfig = {
    allow-import-from-derivation = true;
  };
  inputs = {
    CHaP = {
      flake = false;
      url = "github:intersectmbo/cardano-haskell-packages/repo";
    };
    haskellNix.url = "github:input-output-hk/haskell.nix";
    self.submodules = true;
    utils.url = "github:numtide/flake-utils";
    iohk-nix = {
      url = "github:input-output-hk/iohk-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { nixpkgs, ... }@args: import ./outputs.nix args;
}
