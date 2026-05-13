{ lib
, stdenv
, buildPackages
, fetchFromGitHub
, fetchgit
}:

let
  goDeps = map (dep: dep // {
    src = fetchgit {
      inherit (dep.fetch) url rev sha256;
    };
  }) (import ./deps.nix);
in
stdenv.mkDerivation rec {
  pname = "remarkable_news";
  version = "unstable-2020-09-28";

  goPackagePath = "github.com/Evidlo/remarkable_news";

  src = fetchFromGitHub {
    owner = "Evidlo";
    repo = pname;
    rev = "b74b6ad40a0b7a376dece5fd91100546796a3b2c";
    sha256 = "000id1xg6k6riv89h92fzkxg59rym2i60bh6v02hpdm5ql0wrs6a";
  };

  nativeBuildInputs = [ buildPackages.go ];

  postUnpack = ''
    export GOPATH="$TMPDIR/go"
    mkdir -p "$GOPATH/src/github.com/Evidlo"
    cp -R "$sourceRoot" "$GOPATH/src/${goPackagePath}"
    chmod -R u+w "$GOPATH/src/${goPackagePath}"
    sourceRoot="$GOPATH/src/${goPackagePath}"

    ${lib.concatMapStrings (dep: ''
      mkdir -p "$GOPATH/src/$(dirname "${dep.goPackagePath}")"
      cp -R "${dep.src}" "$GOPATH/src/${dep.goPackagePath}"
      chmod -R u+w "$GOPATH/src/${dep.goPackagePath}"
    '') goDeps}
  '';

  buildPhase = ''
    runHook preBuild

    export GOPATH="$TMPDIR/go"
    export HOME="$TMPDIR"
    export GOCACHE="$TMPDIR/go-build"
    export GO111MODULE=off
    export GOOS=linux
    export GOARCH=arm
    export GOARM=7
    export CGO_ENABLED=0

    go build -v -o remarkable_news .

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 remarkable_news "$out/bin/remarkable_news"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Show daily news/comics on your reMarkable's suspend screen";
    homepage = "https://github.com/Evidlo/remarkable_news";
    license = licenses.gpl3Plus;
    maintainers = [ maintainers.siraben ];
    platforms = platforms.unix;
  };
}
