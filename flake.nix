{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    crane = {
      url = "github:ipetkov/crane";
      inputs = {
        flake-utils.follows = "flake-utils";
        nixpkgs.follows = "nixpkgs";
      };
    };
  };

  outputs = { self, nixpkgs, flake-utils, fenix, crane }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        rust = fenix.packages.${system};
        lib = pkgs.lib;
      in
      {
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; with llvmPackages; [
            # For building.
            clang
            rust.stable.toolchain
            pkg-config
            openssl
            libsodium
            libclang.lib
            # Audio libraries.
            alsaLib
            jack2

          ];

          LIBCLANG_PATH = "${pkgs.llvmPackages.libclang.lib}/lib";
          RUST_BACKTRACE = 1;
          # RUST_LOG = "info,sqlx::query=warn";
          RUSTFLAGS = "-C target-cpu=native";
        };
      });
}
