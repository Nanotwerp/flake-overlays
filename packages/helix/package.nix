{ fetchFromGitHub, lib, rustPlatform, git, installShellFiles }:

rustPlatform.buildRustPackage rec {
  pname = "helix";
  version = "24.05";

  # This release tarball includes source code for the tree-sitter grammars,
  # which is not ordinarily part of the repository.
  src = fetchFromGitHub {
    owner = "helix-editor";
    repo = pname;
    rev = "f1c9580e4b636d014fefb61080d8d019c14e37b7";
    sha256 = "sha256-NtN8mGaqw6SY0V+dO1n+UO1Ywje/M0Rk9b1YnAbkPe8=";
    stripRoot = false;
  };

  cargoHash = "";

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
