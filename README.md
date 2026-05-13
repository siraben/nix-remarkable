# Nix cross-compilation to the reMarkable tablet
This flake builds on the reMarkable cross-compile targets that are now
in Nixpkgs. Package sets for both devices are exposed as
`rm1Pkgs.<package>` and `rm2Pkgs.<package>` flake attributes, and the
overlay extends `pkgsCross.remarkable1` and `pkgsCross.remarkable2`
instead of carrying a separate reMarkable SDK toolchain.

## Cross-compiling using Nixpkgs infrastructure
1. Ensure that your nixpkgs channel is up to date. This repository's
   flake pins `nixpkgs-unstable`; non-flake users need a nixpkgs with
   `pkgsCross.remarkable1` and `pkgsCross.remarkable2`.

```ShellSession
$ nix eval -f '<nixpkgs>' 'pkgsCross.remarkable1.stdenv.hostPlatform.config'
$ nix eval -f '<nixpkgs>' 'pkgsCross.remarkable2.stdenv.hostPlatform.config'
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
4. Install Nix on the device. To do this, fetch the latest 
  armv7l-linux Nix build from https://hydra.nixos.org/jobset/nix/master,
  then un-tar it (`tar -xf ...`) and run the installation script.
  For the multi-user installation, you may have to upgrade busybox or
  edit the script, as the flags provided to `head` in the script aren't
  available on the default binary available on the reMarkable.
  
5. Using `nix-build` and `nix-copy-closure`, one can cross-build from
   their machine and transfer it to the tablet, like so. The
   `NIX_SSHOPTS` is needed because `nix` isn't available unless
   `.profile` is sourced.


```ShellSession
$ NIX_SSHOPTS="source .profile;" nix-copy-closure --to siraben@10.11.99.1 "$(nix build -f '<nixpkgs>' pkgs.pkgsCross.remarkable1.hello)"
```

Happy hacking!

## Building This Repository
Clone and navigate to this repository and run the following to
cross-compile [retris](https://github.com/LinusCDE/retris) to each
tablet generation. If you want to use the binary cache, run
`cachix use nix-remarkable` first.

```sh
nix build .#rm1Pkgs.retris
nix build .#rm2Pkgs.retris
```

## Description
This repository carries Nix expressions for reMarkable tools and uses
Nixpkgs' reMarkable cross infrastructure to build them. The added
benefits are:

- cross-compiling up to 60,000+ additional packages from Nixpkgs
- reproducible builds and deployment, check out the GitHub actions
  artifacts in this repository
- takes advantage of benefits from source and binary deployment by
  using Nix and a binary cache
- allows macOS users to cross-compile to the tablet when used in
  conjunction with
  [nix-docker](https://github.com/LnL7/nix-docker)

Currently, it includes Nix expressions for various tools, including:
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

To build release copies of any of the projects, run `nix build
.#<attribute>` from this repo. The flake exposes:
- `hostPkgs.gst-libvncclient-rfbsrc`
- `rm1Pkgs.appmarkable`
- `rm1Pkgs.chessmarkable`
- `rm1Pkgs.evkill`
- `rm1Pkgs.plato`
- `rm1Pkgs.rM-vnc-server`
- `rm1Pkgs.remarkable-fractals`
- `rm1Pkgs.remarkable_news`
- `rm1Pkgs.retris`
- `rm1Pkgs.rm-video-player`
- `rm2Pkgs.appmarkable`
- `rm2Pkgs.chessmarkable`
- `rm2Pkgs.evkill`
- `rm2Pkgs.plato`
- `rm2Pkgs.rM-vnc-server`
- `rm2Pkgs.remarkable-fractals`
- `rm2Pkgs.remarkable_news`
- `rm2Pkgs.retris`
- `rm2Pkgs.rm-video-player`

To develop your own packages for the reMarkable, use the `rmPkgs`
attribute of the set computed in [default.nix](./default.nix) for
reMarkable 1 compatibility, or use `rm1Pkgs` and `rm2Pkgs` explicitly
when the target generation matters.
