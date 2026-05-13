{ lib, rustPlatform, fetchFromGitHub }:

rustPlatform.buildRustPackage rec {
  pname = "remarkable-fractals";
  version = "unstable-2018-05-01";

  src = fetchFromGitHub {
    owner = "dannyow";
    repo = pname;
    rev = "7931882c15dc16c68736d0261999ee7cadbb4322";
    sha256 = "16maf5381k8kq2w7zsnz9n3vsqpnwghvc9b7z5kx8kgc7q2a6q8f";
  };

  cargoLock = {
    lockFileContents = builtins.readFile "${src}/Cargo.lock";
  };

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
    description = "Draw fractals on the reMarkable tablet";
    homepage = "https://github.com/dannyow/reMarkable-fractals";
    license = licenses.mit;
    maintainers = with maintainers; [ siraben ];
  };
}
