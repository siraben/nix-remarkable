{ lib
, rustPlatform
, fetchFromGitHub
, bzip2
, djvulibre
, freetype
, harfbuzz
, jbig2dec
, libjpeg
, libpng
, mupdf
, openjpeg
, zlib
}:

rustPlatform.buildRustPackage rec {
  pname = "plato";
  version = "0.9.1-rm-release-4";

  src = fetchFromGitHub {
    owner = "LinusCDE";
    repo = pname;
    rev = version;
    sha256 = "1z8h5nz2zf3agzr1d1pjq7a2l6qqdwjg3bcgwz1y7fwag0yh1pvp";
  };

  # the repo specifies the linker to use, which we delete
  patchPhase = ''
    rm .cargo/config
  '';

  cargoLock = {
    lockFileContents = builtins.readFile "${src}/Cargo.lock";
    outputHashes = {
      "libremarkable-0.4.1" = "sha256-PDDvHtFgHuTH8Fj0gXBqT05/QPZ92EQYJ4vmFRg9LzY=";
    };
  };

  buildInputs = [
    bzip2
    djvulibre
    freetype
    harfbuzz
    jbig2dec
    libjpeg
    libpng
    mupdf
    openjpeg
    zlib
  ];

  preBuild = ''
    (
      cd src/mupdf_wrapper
      TARGET_OS=Kobo CFLAGS="$CFLAGS -I${mupdf.dev}/include" ./build.sh
    )

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
    description = "Port of the Plato reader for the reMarkable tablet";
    homepage = "https://github.com/LinusCDE/plato";
    license = licenses.mit;
    maintainers = with maintainers; [ siraben ];
  };
}
