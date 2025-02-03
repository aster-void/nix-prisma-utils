{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        prisma-factory = import ./prisma.nix;
        prisma =
          (pkgs.callPackage ./prisma.nix {
            prisma-fmt-hash = "sha256-4zsJv0PW8FkGfiiv/9g0y5xWNjmRWD8Q2l2blSSBY3s=";
            query-engine-hash = "sha256-6ILWB6ZmK4ac6SgAtqCkZKHbQANmcqpWO92U8CfkFzw=";
            libquery-engine-hash = "sha256-n9IimBruqpDJStlEbCJ8nsk8L9dDW95ug+gz9DHS1Lc=";
            schema-engine-hash = "sha256-j38xSXOBwAjIdIpbSTkFJijby6OGWCoAx+xZyms/34Q=";
          }).fromCommit
            "6a3747c37ff169c90047725a05a6ef02e32ac97e";
      in
      {
        packages = pkgs.callPackage ./tests.nix {
          inherit prisma-factory;
        };
        devShells.default = pkgs.mkShell {
          buildInputs = [
            pkgs.nodejs-18_x
            pkgs.pnpm
            pkgs.bun
            pkgs.stdenv.cc.cc.lib
            prisma.package
            pkgs.nixfmt-rfc-style
          ];
          shellHook = prisma.shellHook;
        };
      }
    )
    // {
      lib = {
        prisma-factory = import ./prisma.nix;
      };
    };
}
