[![built with nix](https://builtwithnix.org/badge.svg)](https://builtwithnix.org)

# Rust Dev Template

This is a template for Rust projects using Nix flakes and direnv. It provides a reproducible and
automatically activating development environment for Rust projects.

## Prerequisites

- [Nix](https://nixos.org/download.html) with flakes enabled
- [direnv](https://direnv.net/)
- [nix-direnv](https://github.com/nix-community/nix-direnv)
- [Visual Studio Code](https://code.visualstudio.com/) (recommended)

## Getting Started

1. Use this template to create a new repository.

2. Clone your new repository:

```bash
git clone https://github.com/yourusername/your-repo-name.git
cd your-repo-name
```

3. Update the project name:
- In `Cargo.toml`, change the `name` field under `[package]` to your project name.
- In `flake.nix`, update the `pname` in the `packages.default` definition to your project name.

4. Allow direnv for this project:

```bash
direnv allow
```

This will automatically set up and enter the Rust development environment defined in the flake.

## VS Code Setup

This project includes configurations for Visual Studio Code to enhance your development experience.

### Recommended Extensions

The following extensions are recommended for this project:

- [rust-lang.rust-analyzer][rust-analyzer]
- [jnoortheen.nix-ide][nix-ide]
- [mkhl.direnv][direnv]
- [vadimcn.vscode-lldb][vscode-lldb]
- [serayuzgur.crates][crates]
- [tamasfe.even-better-toml][even-better-toml]
- [usernamehw.errorlens][errorlens]
- [eamodio.gitlens][gitlens]
- [streetsidesoftware.code-spell-checker][code-spell-checker]

You can install these extensions manually,
[through Nix][nixos-wiki-vscode], or VS Code will prompt you to
install them when you open the project.

[rust-analyzer]: https://marketplace.visualstudio.com/items?itemName=rust-lang.rust-analyzer
[nix-ide]: https://marketplace.visualstudio.com/items?itemName=jnoortheen.nix-ide
[direnv]: https://marketplace.visualstudio.com/items?itemName=mkhl.direnv
[vscode-lldb]: https://marketplace.visualstudio.com/items?itemName=vadimcn.vscode-lldb
[crates]: https://marketplace.visualstudio.com/items?itemName=serayuzgur.crates
[even-better-toml]: https://marketplace.visualstudio.com/items?itemName=tamasfe.even-better-toml
[errorlens]: https://marketplace.visualstudio.com/items?itemName=usernamehw.errorlens
[gitlens]: https://marketplace.visualstudio.com/items?itemName=eamodio.gitlens
[code-spell-checker]: https://marketplace.visualstudio.com/items?itemName=streetsidesoftware.code-spell-checker
[nixos-wiki-vscode]: https://nixos.wiki/wiki/Visual_Studio_Code

## Debugging

### VS Code

This project includes a ```launch.json``` file for debugging Rust code in VS Code.
To start debugging:

1. Open the Debug view in VS Code (Ctrl+Shift+D or Cmd+Shift+D on macOS).

2. Select either "Debug executable" or "Debug unit tests" from the dropdown at the top of
the Debug view.

3. Set breakpoints in your code as needed.

4. Press F5 or click the green play button to start debugging.

### Terminal

You can use the ```debug``` command provided by the flake:

```bash
nix run .#debug
```

This will start LLDB and attach it to your project's binary.

## Customizing the Template

1. Update the `Cargo.toml` file:
- Modify the `name`, `version`, `authors`, and `description` fields.
- Add or modify dependencies as needed for your project.

2. Modify the `flake.nix` file:
- Update the `description` at the top of the file.
- If you need to add or change Nix dependencies, modify the `buildInputs` in the
`devShells.default`section.
- If you've added any Rust dependencies that require system libraries, you may need to add them to
the `buildInputs` of the `packages.default` definition.

3. Add your Rust code to the `src` directory.

4. If needed, adjust the `.envrc` file to add any project-specific environment variables
or settings.

5. Update this README.md file to describe your project.

6. (Optional) Modify the GitHub Actions workflow in `.github/workflows/` if you need to
customize the CI/CD process.

Remember to commit these changes:

```bash
git add .
git commit -m "Customize project template"
```

## Automatic Environment Activation

Once direnv is allowed, it will automatically activate the Nix-defined development environment
whenever you enter the project directory. You'll see a message indicating that the environment
has been loaded.

## Available Commands

With the environment activated, you can use the following commands:

- `cargo build`: Build the project
- `cargo test`: Run tests
- `cargo run`: Run the project
- `cargo fmt`: Format the code
- `cargo clippy`: Run the linter

Additionally, this template provides the following Nix commands:

- `nix run .#build`: Build the project in release mode
- `nix run .#run`: Run the project in release mode
- `nix run .#test`: Run tests
- `nix run .#coverage`: Generate code coverage report
- `nix run .#lint`: Run the linter
- `nix run .#format`: Format both Rust and Nix files
- `nix run .#clean`: Clean up build artifacts

## Customizing the Template

1. Update the `Cargo.toml` file with your project details.
2. Modify the `flake.nix` file if you need to add or change dependencies.
3. Add your Rust code to the `src` directory.
4. If needed, adjust the `.envrc` file to add any project-specific environment variables or settings.

## CI/CD

This template includes a GitHub Actions workflow for CI/CD. It will automatically build, test, and
lint your project on each push and pull request.

## Creating Releases

To create a release:

1. Tag your commit:

```bash
git tag -a v1.0.0 -m "Release 1.0.0"
git push origin v1.0.0
```

2. The GitHub Actions workflow will automatically create a release and attach the built binary.

## Contributing

Contributions are welcome. Please feel free to submit a Pull Request.

## Troubleshooting

If you encounter any issues with direnv or the Nix environment:

1. Ensure that direnv and nix-direnv are correctly installed and configured.
2. Try running `direnv reload` in the project directory.
3. Check the `.envrc` and `flake.nix` files for any potential issues.
