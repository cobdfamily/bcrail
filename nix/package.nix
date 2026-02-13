{ lib, stdenvNoCC, makeWrapper, bash, coreutils, gawk, gnused, gnutar, gzip, jq, openssh, wget, incus }:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "bcrail";
  version = "0.1.0";

  src = lib.cleanSource ../.;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/bin" "$out/libexec/bcrail" "$out/share/bcrail"
    cp -r bin/. "$out/bin/"
    cp -r libexec/bcrail/. "$out/libexec/bcrail/"
    cp etc/bcrail/ignition.json "$out/share/bcrail/ignition.json"
    cp etc/bcrail/locomotive.env "$out/share/bcrail/locomotive.env"

    patchShebangs "$out/bin" "$out/libexec"

    wrapProgram "$out/bin/bcrail" \
      --set BCRAIL_LIBEXEC_DIR "$out/libexec/bcrail" \
      --prefix PATH : ${lib.makeBinPath [
        bash
        coreutils
        gawk
        gnused
        gnutar
        gzip
        jq
        openssh
        wget
        incus
      ]}

    wrapProgram "$out/bin/docker" \
      --prefix PATH : ${lib.makeBinPath [
        bash
        coreutils
        gawk
        gnused
        gnutar
        gzip
        jq
        openssh
        wget
        incus
      ]}

    runHook postInstall
  '';

  meta = {
    description = "BCRail environment tooling for Flatcar/Incus runners";
    platforms = lib.platforms.linux;
    mainProgram = "bcrail";
    license = lib.licenses.mit;
  };
})
