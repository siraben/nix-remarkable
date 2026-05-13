{ lib, rustPlatform, fetchFromGitHub }:

rustPlatform.buildRustPackage rec {
  pname = "rm-video-player";
  version = "unstable-2020-10-17";

  src = fetchFromGitHub {
    owner = "LinusCDE";
    repo = pname;
    rev = "9cb4708f93c8db6277193329ed29626b0fe0ef70";
    sha256 = "0pzm095mrw1rllikyf3xm163znvs7gzi4wcklsasabsijmhli1pk";
  };

  # the repo specifies the linker to use, which we delete
  patchPhase = ''
    rm .cargo/config
  '';

  cargoHash = "sha256-R2Rh6b7Ft1d+8t1JFCxP5B4/lYcNT6IHDcSDPCNVhE8=";

  preBuild = ''
    for serialize in $(find .. -path '*/rustc-serialize-0.3.24/src/serialize.rs'); do
      substituteInPlace "$serialize" \
        --replace-fail "impl<'a, T: ?Sized> Decodable for Cow<'a, T>" \
                       "impl<'a, T: ?Sized + 'static> Decodable for Cow<'a, T>"
    done

    for rustFile in $(find .. \( -path '*/num-bigint-*/src/*.rs' -o -path '*/num-complex-*/src/*.rs' -o -path '*/num-rational-*/src/*.rs' \)); do
      if grep -q 'feature = "rustc-serialize"' "$rustFile"; then
        substituteInPlace "$rustFile" \
          --replace-fail 'feature = "rustc-serialize"' 'feature = "disabled-rustc-serialize"'
      fi
    done

    for atomicFile in $(find .. -path '*/atomic-*/src/lib.rs'); do
      if grep -q 'feature = "nightly"' "$atomicFile"; then
        substituteInPlace "$atomicFile" \
          --replace-fail 'feature = "nightly"' 'feature = "disabled-nightly"'
      fi
    done

    for libremarkableFile in $(find .. -path '*/libremarkable-*/src/lib.rs'); do
      sed -i '/^#!\[feature(/d' "$libremarkableFile"
    done

    for appctxFile in $(find .. -path '*/libremarkable-*/src/appctx.rs'); do
      if grep -q 'box core::Framebuffer::new("/dev/fb0")' "$appctxFile"; then
        substituteInPlace "$appctxFile" \
          --replace-fail 'box core::Framebuffer::new("/dev/fb0")' \
                         'Box::new(core::Framebuffer::new("/dev/fb0"))'
      fi
    done
  '';

  meta = with lib; {
    description = " PoC of playing some kind of video for some time on the reMarkable ";
    homepage = "https://github.com/LinusCDE/rm-video-player";
    license = licenses.mit;
    maintainers = with maintainers; [ siraben ];
  };
}
