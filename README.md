# Cross-compilation to the reMarkable tablet using Nix

## Quick start
Clone and navigate to this repository and run the following to
cross-compile [retris](https://github.com/LinusCDE/retris) to the
reMarkable tablet.  If you want to use the binary cache (recommended),
run `cachix use nix-remarkable` first.

```sh
nix build --arg release true -f . rmPkgs.retris
```

## Description
This repository adapts [reMarkable's
toolchain](http://remarkable.engineering/) to be compatible with Nix.
The added benefits are;

- cross-compiling up to 60,000+ additional packages from Nixpkgs
- reproducible builds and deployment, check out the GitHub actions
  artifacts in this repository
- takes advantage of benefits from source and binary deployment by
  using Nix and a binary cache
- allows macOS users to cross-compile to the tablet when used in
  conjunction with
  [linuxkit-nix](https://github.com/nix-community/linuxkit-nix)

Currently, it includes both a Nixpkgs cross configuration for the
reMarkable, and Nix expressions for various tools, including
- [appmarkable](https://github.com/LinusCDE/appmarkable)
- [chessMarkable](https://github.com/LinusCDE/chessmarkable)
- [evkill](https://github.com/Enteee/evkill)
- [gst-libvncclient-rfbsrc](https://github.com/peter-sa/gst-libvncclient-rfbsrc)
- [mxc_epdc_fb_damage](https://github.com/peter-sa/mxc_epdc_fb_damage)
- [plato](https://github.com/LinusCDE/plato)
- [rM-vnc-server](https://github.com/peter-sa/rM-vnc-server)
- [remarkable-fractals](https://github.com/dannyow/reMarkable-fractals)
- [remarkable_news](https://github.com/Evidlo/remarkable_news)
- [retris](https://github.com/LinusCDE/retris)
- [rm-video-player](https://github.com/LinusCDE/rm-video-player)

To build a local copy of the above packages, create a `pkgs/`
directory, clone the relevant repository into it, and run `nix build`
in the resulting subdirectory.

To build release copies of any of the projects, run `nix build --arg
release true -f . <attribute path>` from this repo (without needing to
manually download anything else), where `<attribute path>` is one of:
- `hostPkgs.gst-libvncclient-rfbsrc`
- `rmPkgs.appmarkable`
- `rmPkgs.chessmarkable`
- `rmPkgs.evkill`
- `rmPkgs.linuxPackages.mxc_epdc_fb_damage`
- `rmPkgs.plato`
- `rmPkgs.rM-vnc-server`
- `rmPkgs.remarkable-fractals`
- `rmPkgs.remarkable_news`
- `rmPkgs.retris`
- `rmPkgs.rm-video-player`

To develop your own packages for the reMarkable, use the `rmPkgs`
attribute of the set computed in [default.nix](./default.nix) as a
`nixpkgs` appropriately configured for cross-compilation (e.g. its
`stdenv.mkDerivation` will generate derivations that cross-build for
the reMarkable).
