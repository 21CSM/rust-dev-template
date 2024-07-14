{
  description = "Dev environment for Rust based on Nix flakes";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, fenix, flake-utils, pre-commit-hooks, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ fenix.overlays.default ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };

        fx = fenix.packages.${system};
        rustToolchain = fx.complete.withComponents [
          "cargo"
          "clippy"
          "rust-src"
          "rustc"
          "rustfmt"
        ];

        cargoTools = with pkgs; [
          cargo-watch
          cargo-audit
          cargo-tarpaulin
          cargo-outdated
          cargo-expand
          cargo-update
        ];

        pre-commit-check = pre-commit-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            nixpkgs-fmt.enable = true;
            rustfmt = {
              enable = true;
              entry = pkgs.lib.mkForce "${rustToolchain}/bin/rustfmt";
            };
          };
        };

        commonArgs = {
          src = ./.;
          cargoLock = {
            lockFile = ./Cargo.lock;
          };
        };

      in
      with pkgs; {
        devShells.default = mkShell {
          buildInputs = [
            rustToolchain
            rust-analyzer
            nixpkgs-fmt
            pre-commit
          ] ++ cargoTools;

          shellHook = ''
            echo "Rust development environment"
            ${pre-commit-check.shellHook}
          '';

          RUST_SRC_PATH = "${rustToolchain}/lib/rustlib/src/rust/library";
          RUST_BACKTRACE = 1;
          RUSTFLAGS = "-C target-cpu=native";
          CARGO_HOME = "./.cargo";
        };

        checks = {
          pre-commit-check = pre-commit-check;
        };

        formatter = nixpkgs-fmt;

        packages = {
          default = pkgs.rustPlatform.buildRustPackage (commonArgs // {
            pname = "rust-dev-template";
            version = "0.1.0";
          });
        };

        apps = {
          default = flake-utils.lib.mkApp { drv = self.packages.${system}.default; };

          build = flake-utils.lib.mkApp {
            drv = pkgs.writeShellScriptBin "build" ''
              echo "Building in release mode..."
              ${rustToolchain}/bin/cargo build --release
            '';
          };

          run = flake-utils.lib.mkApp {
            drv = pkgs.writeShellScriptBin "run" ''
              echo "Running in release mode..."
              ${rustToolchain}/bin/cargo run --release
            '';
          };

          test = flake-utils.lib.mkApp {
            drv = pkgs.writeShellScriptBin "test" ''
              ${rustToolchain}/bin/cargo test $@
            '';
          };

          coverage = flake-utils.lib.mkApp {
            drv = pkgs.writeShellScriptBin "coverage" ''
              ${rustToolchain}/bin/cargo tarpaulin --out Xml --out Html --out Json --output-dir ./coverage $@
            '';
          };

          lint = flake-utils.lib.mkApp {
            drv = pkgs.writeShellScriptBin "lint" ''
              ${rustToolchain}/bin/cargo clippy -- -D warnings $@
            '';
          };

          format = flake-utils.lib.mkApp {
            drv = pkgs.writeShellScriptBin "format" ''
              ${rustToolchain}/bin/cargo fmt
              ${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt .
            '';
          };

          clean = flake-utils.lib.mkApp {
            drv = pkgs.writeShellScriptBin "clean" ''
              echo "Cleaning up build artifacts..."
              ${rustToolchain}/bin/cargo clean
              rm -rf ./coverage
              rm -f ./result
              echo "Clean complete."
            '';
          };
        };
      }
    );
}
