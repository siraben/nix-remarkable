{ stdenv, lib, fetchFromGitHub, rm-toolchain }:

stdenv.mkDerivation {
  name = "oxide";
  src = fetchFromGitHub {
    owner = "Eeems";
    repo = "oxide";
    # from v2.1 branch
    rev = "935865946fe0e95e58a07077bdb6cf73d32442e4";
    sha256 = "18crnxrcrfkrlc894bj8mnslhqf49n3pb0pw7jr41jv303aizp5f";
  };

  nativeBuildInputs = [ rm-toolchain ];
  QMAKESPEC = "${rm-toolchain}/sysroots/cortexa9hf-neon-oe-linux-gnueabi/usr/lib/mkspecs/linux-oe-g++";

  buildPhase = ''
    make release
  '';
}
