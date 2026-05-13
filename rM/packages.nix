srcs: self: super:

{
  linuxPackages = super.linuxPackages.extend
    (selflp: superlp: {
      mxc_epdc_fb_damage = selflp.callPackage srcs.mxc_epdc_fb_damage.drv {
        stdenv = selflp.stdenv // {
          hostPlatform = selflp.stdenv.hostPlatform // {
            platform = (selflp.stdenv.hostPlatform.platform or {}) // {
              kernelArch = "arm";
            };
          };
        };
      };
    });
  appmarkable = self.callPackage ./pkgs/appmarkable {};
  chessmarkable = self.callPackage ./pkgs/chessmarkable {};
  evkill = self.callPackage ./pkgs/evkill {};
  plato = self.callPackage ./pkgs/plato {};
  rM-vnc-server = self.callPackage srcs.rM-vnc-server.drv {};
  remarkable-fractals = self.callPackage ./pkgs/remarkable-fractals {};
  remarkable_news = self.callPackage ./pkgs/remarkable_news {};
  retris = self.callPackage ./pkgs/retris {};
  rm-video-player = self.callPackage ./pkgs/rm-video-player {};
}
