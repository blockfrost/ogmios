system: { self, haskellNix, utils, nixpkgs, CHaP, iohk-nix }:

let
  overlays = [
    iohk-nix.overlays.crypto
    haskellNix.overlay
  ];
  mkGitHook = revision: let
    hook = pkgs.writeShellScriptBin "git" ''
      echo ${revision}
    '';
  in {
    packages.ogmios.components.library.build-tools = [hook];
  };
  pkgs = import nixpkgs { inherit overlays system; config.allowAliases = false; };
  ogmios-project = pkgs.haskell-nix.project {
    compiler-nix-name = "ghc967";
    inputMap = {
      "https://input-output-hk.github.io/cardano-haskell-packages" = CHaP;
      "https://chap.intersectmbo.org/" = CHaP;
    };
    projectFileName = "cabal.project";
    src = ./server;
    modules = [
      (mkGitHook self.rev)
      ({ lib, pkgs, ... }:
      {
        packages.cardano-crypto-class.components.library.pkgconfig = lib.mkForce [ [ pkgs.libsodium-vrf pkgs.secp256k1 pkgs.libblst ] ];
      })
    ];
  };
in {
  inherit ogmios-project;
  inherit (pkgs) libblst;
}
