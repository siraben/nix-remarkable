release: _nixpkgs:

let
  bootPkgs = import _nixpkgs {};

  nixpkgs = if release then bootPkgs.fetchFromGitHub {
    owner = "NixOS";
    repo = "nixpkgs";
    # nixpkgs-unstable 2020-11-29
    rev = "db103e0f98d461f3e66cd68702492afca0810db5";
    sha256 = "19gz926nqv7ggq281mv2qi1ah6a5slg2vvhsvc5jdnkp28m8f55k";
  } else _nixpkgs;
in with import nixpkgs {}; let
  upstreamOrLocal = name: ghArgs:
    let path = ./pkgs + ("/" + name) + /derivation.nix; in
    if !release && builtins.pathExists path
    then { drv = path; }
    else let src = fetchFromGitHub ({ repo = name; } // ghArgs); in
         src // { drv = src + "/derivation.nix"; };
in

{
  inherit nixpkgs;

  mxc_epdc_fb_damage = upstreamOrLocal "mxc_epdc_fb_damage" {
    owner = "peter-sa";
    rev = "v0.0.1";
    sha256 = "1pmxy9f9w9skqzshq5da1ab8l83q3l363b0c7k6c877r1jlwf2vv";
  };
  rM-vnc-server = upstreamOrLocal "rM-vnc-server" {
    owner = "peter-sa";
    rev = "v0.0.1";
    sha256 = "0b6ragczvi40l9za468jv79xb0n84nvca8pd3m5w05nfmgsglp33";
  };
  gst-libvncclient-rfbsrc = upstreamOrLocal "gst-libvncclient-rfbsrc" {
    owner = "peter-sa";
    rev = "v0.0.1";
    sha256 = "0ihd6r5qzz3g49yzylfqa730c0l0jri6l1s2k63i1q1l2r339yrz";
  };
}
