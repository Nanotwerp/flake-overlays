{ fetchpatch2, fetchzip, lib, rustPlatform, git, installShellFiles }:

rustPlatform.buildRustPackage rec {
  pname = "helix";
  version = "24.03";

  # This release tarball includes source code for the tree-sitter grammars,
  # which is not ordinarily part of the repository.
  src = fetchzip {
    url = "https://github.com/helix-editor/helix/releases/download/${version}/helix-${version}-source.tar.xz";
    hash = "sha256-1myVGFBwdLguZDPo1jrth/q2i5rn5R2+BVKIkCCUalc=";
    stripRoot = false;
  };

  cargoHash = "sha256-THzPUVcmboVJHu3rJ6rev3GrkNilZRMlitCx7M1+HBE=";

  patches = [
    (fetchpatch2 {
      url = "https://raw.githubusercontent.com/Nanotwerp/nanonixpatches/1792030ada880770f3791e9f551b8b50707567a1/helix/lldb-dap.patch";
      hash = "sha256-3PfSStAdq1Ijeucy6dKXTh3G/v579wf7/XNWfbJSevs=";
    })
  ];

  nativeBuildInputs = [ git installShellFiles ];

  env.HELIX_DEFAULT_RUNTIME = "${placeholder "out"}/lib/runtime";

  postInstall = ''
    # not needed at runtime
    rm -r runtime/grammars/sources

    mkdir -p $out/lib
    cp -r runtime $out/lib
    installShellCompletion contrib/completion/hx.{bash,fish,zsh}
    mkdir -p $out/share/{applications,icons/hicolor/256x256/apps}
    cp contrib/Helix.desktop $out/share/applications
    cp contrib/helix.png $out/share/icons/hicolor/256x256/apps
  '';

  meta = with lib; {
    description = "A post-modern modal text editor";
    homepage = "https://helix-editor.com";
    license = licenses.mpl20;
    mainProgram = "hx";
    maintainers = with maintainers; [ danth yusdacra zowoq ];
  };
}
