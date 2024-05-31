{
  description = "Some miscellaneous packages";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable-small";
  };

  outputs =
    { self, nixpkgs }:
    let
      forAllSystems =
        f:
        nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed (
          system:
          f {
            inherit system;
            pkgs = import nixpkgs { inherit system; };
          }
        );
    in
    {
      packages = forAllSystems (
        { system, pkgs }:
        let
          bitwig-studio-beta = pkgs.callPackage ./packages/bitwig-studio-beta/package.nix { };
        in
        {
          inherit bitwig-studio-beta;
          default = bitwig-studio-beta;
        }
      );
    };
}
