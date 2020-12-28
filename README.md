# Nix cross-compilation to the reMarkable tablet
**Note:**  The reMarkable 1 and 2 have been added as cross-compile
targets to Nixpkgs.  As such, if you want to build things from source
and not trust the company's toolchain, follow these instructions

## Cross-compiling using Nixpkgs infrastructure
1. Ensure that your nixpkgs channel is up to date (or equivalent with
   niv and flakes). You can check if it can cross-compile to
   reMarkable 1 by running the following, replace with `remarkable2`
   to check the same for reMarkable 2.

```ShellSession
$ nix eval -f '<nixpkgs>' 'lib.systems.examples.remarkable1'
```
2. Create a non-root user on the tablet, e.g. `useradd siraben &&
   passwd siraben`.  Ensure that you have passwordless SSH set up by
   using `ssh-copy-id`.

3. The root partition on the  tablet has very limited space (22 MB),
   so, as root, `mkdir -p /nix /opt/nix && mount --bind /opt/nix
   /nix`. The bind can be made persistent by adding the following line
   to `/etc/fstab`

```
/opt/nix /nix none bind,nofail 0,0
```
4. Install Nix on the device. I used
   https://github.com/DavHau/nix-on-armv7l and decompressed the
   tarball in the releases and ran the install script.

5. Using `nix-build` and `nix-copy-closure`, one can cross-build from
   their machine and transfer it to the tablet, like so. The
   `NIX_SSHOPTS` is needed because `nix` isn't available unless
   `.profile` is sourced.


```ShellSession
$ NIX_SSHOPTS="source .profile;" nix-copy-closure --to siraben@10.11.99.1 "$(nix-build '<nixpkgs>' -A pkgs.pkgsCross.remarkable1.hello)"
```

Happy hacking!

## Cross-compiling using reMarkable's toolchain
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
