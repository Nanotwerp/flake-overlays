{
  description = "A simple, fast and user-friendly alternative to `find`";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable-small";

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, rust-overlay }:
    let
      overlays = [ (import rust-overlay) ];

      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f {
        pkgs = import nixpkgs { inherit system overlays; };
        system = system;
      });
    in
    {
      packages =
        let
          fd-nightly = forAllSystems ({ system, pkgs }:
            let
              rustPlatform = pkgs.makeRustPlatform {
                cargo = pkgs.rust-bin.nightly.latest.default;
                rustc = pkgs.rust-bin.nightly.latest.default;
              };
            in
            rustPlatform.buildRustPackage rec {
              pname = "fd-nightly";
              version = "10.1.0";

              src = pkgs.fetchFromGitHub {
                owner = "sharkdp";
                repo = "fd";
                rev = "v${version}";
                hash = "sha256-9fL2XV3Vre2uo8Co3tlHYIvpNHNOh5TuvZggkWOxm5A=";
              };
              cargoHash = "sha256-3TbsPfAn/GcGASc0RCcyAeUiD4RUtvTATdTYhKdBxvo=";

              nativeBuildInputs = [ nixpkgs.installShellFiles pkgs.mold ];

              buildInputs = with pkgs; [ rust-jemalloc-sys ];

              postInstall = ''
                installManPage doc/fd.1

                installShellCompletion --cmd fd \
                  --bash <($out/bin/fd --gen-completions bash) \
                  --fish <($out/bin/fd --gen-completions fish)
                installShellCompletion --zsh contrib/completion/_fd
              '';

              passthru.tests.version = nixpkgs.testers.testVersion {
                package = pkgs.fd;
              };

              meta = with nixpkgs.lib; {
                description = "A simple, fast and user-friendly alternative to find";
                longDescription = ''
                  `fd` is a simple, fast and user-friendly alternative to `find`.

                  While it does not seek to mirror all of `find`'s powerful functionality,
                  it provides sensible (opinionated) defaults for 80% of the use cases.
                '';
                homepage = "https://github.com/sharkdp/fd";
                changelog = "https://github.com/sharkdp/fd/blob/v${version}/CHANGELOG.md";
                license = with licenses; [ asl20 /* or */ mit ];
                maintainers = with maintainers; [ dywedir figsoda globin ma27 zowoq ];
                mainProgram = "fd";
              };
            }
          );
        in
        {
          inherit fd-nightly;
          default = fd-nightly;
        };
    };
}
