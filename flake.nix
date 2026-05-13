{
  description = "Various programs for the reMarkable tablet";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
      mkPkgs = system: import ./default.nix { inherit nixpkgs system; };
      mkPackages = system:
        let
          pkgs = mkPkgs system;
        in
        {
          inherit (pkgs.hostPkgs) gst-libvncclient-rfbsrc;
        };
    in
    {
      packages = forAllSystems mkPackages;
      legacyPackages = forAllSystems mkPkgs;

      overlay = final: prev: {
        inherit (mkPkgs final.system) rmPkgs rm1Pkgs rm2Pkgs hostPkgs;
      };
    };
}
