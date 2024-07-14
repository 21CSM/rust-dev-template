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

        cargoTools = [
          pkgs.cargo-watch
          pkgs.cargo-audit
          pkgs.cargo-tarpaulin
          pkgs.cargo-outdated
          pkgs.cargo-expand
          pkgs.cargo-update
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
      {
        devShells.default = pkgs.mkShell {
          buildInputs = [
            rustToolchain
            pkgs.rust-analyzer
            pkgs.nixpkgs-fmt
            pkgs.pre-commit
          ] ++ cargoTools
          ++ pkgs.lib.optional (pkgs ? lldb) pkgs.lldb;

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

        formatter = pkgs.nixpkgs-fmt;

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

          debug = flake-utils.lib.mkApp {
            drv = pkgs.writeShellScriptBin "debug" ''
              echo "Building in debug mode..."
              ${rustToolchain}/bin/cargo build

              echo "Determining binary name and path..."
              binary_name=$(${rustToolchain}/bin/cargo metadata --no-deps --format-version 1 \
                | ${pkgs.jq}/bin/jq -r \
                '.packages[0].targets[] | select(.kind[] | contains("bin")) | .name')
              binary_path="target/debug/$binary_name"

              if [ ! -f "$binary_path" ]; then
                echo "Error: Binary not found at $binary_path"
                exit 1
              fi

              echo "Starting rust-lldb for $binary_name..."
              ${rustToolchain}/bin/rust-lldb "$binary_path"
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
