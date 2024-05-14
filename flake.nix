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
      packages = forAllSystems ({ system, pkgs }:
        let
          rustPlatform = pkgs.makeRustPlatform {
            cargo = pkgs.rust-bin.nightly.latest.default;
            rustc = pkgs.rust-bin.nightly.latest.default;
          };
        in
        let
          fd-nightly = pkgs.callPackage ./packages/fd/package.nix { };
        in
        {
          inherit fd-nightly;
          default = fd-nightly;
        }
      );
    };
}
