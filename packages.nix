system: { self, haskellNix, utils, nixpkgs, CHaP, iohk-nix }:

let
  overlays = [
    iohk-nix.overlays.crypto
    haskellNix.overlay
    iohk-nix.overlays.haskell-nix-crypto
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
    supportHpack = false;
    inputMap = {
      "https://input-output-hk.github.io/cardano-haskell-packages" = CHaP;
      "https://chap.intersectmbo.org/" = CHaP;
    };
    projectFileName = "cabal.project";
    src =
      # just /server subdir and filter package.yaml
      # otherwise it fails on missing .hpack something yaml
      pkgs.haskell-nix.haskellLib.cleanSourceWith {
        name = "ogmios-src";
        src = ./.;
        subDir = "server";
        filter = path: type:
          builtins.all (x: x) [
            (baseNameOf path != "package.yaml")
          ];
      };
    modules = [
      #(mkGitHook self.rev)
      ({ lib, pkgs, ... }:
      {
        packages.cardano-crypto-class.components.library.pkgconfig = lib.mkForce [ [ pkgs.libsodium-vrf pkgs.secp256k1 pkgs.libblst ] ];
      })
    ];
  };
in {
  default = ogmios-project.ogmios.components.exes.ogmios;
  inherit (pkgs) libblst;
}
