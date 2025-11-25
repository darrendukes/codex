# Building codex-dd Custom Distribution

This document describes how to build and publish your custom `codex-dd` npm package.

## Overview

The `codex-dd` package is a custom distribution of OpenAI's Codex CLI with the following modifications:
- Package name: `codex-dd` (instead of `@openai/codex`)
- Binary commands: Both `codex-dd` and `codex` are available
- Includes your custom changes from the `ddukes/codex-dd` branch

## Building from Source (Recommended)

To build with your local changes:

### Quick Method (Using the Build Script)

```bash
./build-codex-dd.sh [version]
# Example: ./build-codex-dd.sh 1.0.1-custom
```

### Manual Method

If you prefer to build step-by-step:

### 1. Install Rust (one-time setup)

```bash
brew install rustup
rustup-init -y
. "$HOME/.cargo/env"
```

### 2. Build the Codex binary

```bash
cd /Users/ddukes/codex/codex-rs
cargo build --release -p codex-cli
```

The binary will be at: `codex-rs/target/release/codex`

### 3. Create the npm package

```bash
cd /Users/ddukes/codex

# Set up vendor directory with your custom binary
rm -rf /tmp/vendor
mkdir -p /tmp/vendor/aarch64-apple-darwin/codex
mkdir -p /tmp/vendor/aarch64-apple-darwin/path

# Copy your built binary and ripgrep
cp codex-rs/target/release/codex /tmp/vendor/aarch64-apple-darwin/codex/
cp /opt/homebrew/bin/rg /tmp/vendor/aarch64-apple-darwin/path/

# Build the npm package
rm -rf /tmp/codex-dd-stage
python3 codex-cli/scripts/build_npm_package.py \
  --package codex \
  --version 1.0.0-custom \
  --vendor-src /tmp/vendor \
  --staging-dir /tmp/codex-dd-stage \
  --pack-output dist/codex-dd-1.0.0-custom.tgz
```

## Quick Build (Using Pre-installed Binary)

## Alternative: Using Pre-installed Binary

If you just want to package an existing Codex installation without your custom changes:

```bash
cd /Users/ddukes/codex

# Find the Homebrew-installed binary
CODEX_BIN=$(find /opt/homebrew/Cellar/codex -name codex -type f -perm +111 | head -1)

# 1. Set up vendor directory with binaries
rm -rf /tmp/vendor
mkdir -p /tmp/vendor/aarch64-apple-darwin/codex
mkdir -p /tmp/vendor/aarch64-apple-darwin/path

# 2. Copy binaries
cp "$CODEX_BIN" /tmp/vendor/aarch64-apple-darwin/codex/
cp /opt/homebrew/bin/rg /tmp/vendor/aarch64-apple-darwin/path/

# 3. Build the npm package
rm -rf /tmp/codex-dd-stage
python3 codex-cli/scripts/build_npm_package.py \
  --package codex \
  --version 1.0.0 \
  --vendor-src /tmp/vendor \
  --staging-dir /tmp/codex-dd-stage \
  --pack-output dist/codex-dd-1.0.0.tgz
```

## Testing Locally

Install the package globally:

```bash
npm install -g --force dist/codex-dd-1.0.0.tgz
```

Test it:

```bash
codex-dd --version
codex-dd --help
```

## Package Configuration

The package configuration is in `codex-cli/package.json`:

```json
{
  "name": "codex-dd",
  "version": "1.0.0",
  "license": "Apache-2.0",
  "bin": {
    "codex-dd": "bin/codex.js",
    "codex": "bin/codex.js"
  }
}
```

## Publishing to npm

To publish to npm registry:

```bash
cd /tmp/codex-dd-stage
npm publish
```

Or if using a scoped package (e.g., `@ddukes/codex-dd`):

```bash
npm publish --access public
```

## Building for Multiple Platforms

The current build only includes macOS ARM64 binaries. For a multi-platform distribution:

1. Build or obtain binaries for each platform:
   - `aarch64-apple-darwin` (macOS ARM64)
   - `x86_64-apple-darwin` (macOS Intel)
   - `x86_64-unknown-linux-musl` (Linux x64)
   - `aarch64-unknown-linux-musl` (Linux ARM64)
   - `x86_64-pc-windows-msvc` (Windows x64)

2. Copy each to `/tmp/vendor/<platform>/codex/codex` and `/tmp/vendor/<platform>/path/rg`

3. Build once with all platforms included

## File Locations

- Package definition: `codex-cli/package.json`
- Build script: `codex-cli/scripts/build_npm_package.py`
- Launcher script: `codex-cli/bin/codex.js`
- Built package: `dist/codex-dd-1.0.0.tgz`

## Version Management

To update the version:

1. Edit `codex-cli/package.json` and change the `version` field
2. Update the `--version` parameter when running the build script
3. Rebuild the package

## Notes

- The `--force` flag when installing with npm is needed because both `codex` and `codex-dd` create a `codex` symlink
- The Apache-2.0 license must be maintained per the original project's license
- This is a fork/custom distribution - maintain proper attribution to the original OpenAI project
