{ lib, rustPlatform, fetchFromGitHub }:

rustPlatform.buildRustPackage rec {
  pname = "appmarkable";
  version = "unstable-2020-10-17";

  src = fetchFromGitHub {
    owner = "LinusCDE";
    repo = pname;
    rev = "b3b68dbe8faf4d5faed9d87dd127034885bc5289";
    sha256 = "116q3gbvj741vdxmjj16pny4xkhxgqywhmyi98y03mppw6bgpzhb";
  };

  # the repo specifies the linker to use, which we delete
  patchPhase = ''
    rm .cargo/config
  '';

  cargoHash = "sha256-0O37wSl5YJ9syejnzwzdQ9nr7sINjVRwn8CMjHRq3GQ=";

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
    description = "Turn your program into a very simple app for draft similar";
    homepage = "https://github.com/LinusCDE/appmarkable";
    license = licenses.mit;
    maintainers = with maintainers; [ siraben ];
  };
}
