# if release is not set, import packages from subdirectories if they exist
{ release ? false
, nixpkgs ? <nixpkgs>
, system ? "x86_64-linux"
, srcs ? import ./srcs.nix { inherit release nixpkgs system; }
}:

let
  pkgs = import nixpkgs { inherit system; };
  rmOverlay = import ./rM/packages.nix srcs;
in
rec {
  rm1Pkgs = pkgs.pkgsCross.remarkable1.extend rmOverlay;
  rm2Pkgs = pkgs.pkgsCross.remarkable2.extend rmOverlay;
  rmPkgs = rm1Pkgs;
  hostPkgs = pkgs.extend (import ./host/packages.nix srcs);
}
