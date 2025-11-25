#!/bin/bash
# Build and package codex-dd with local changes

set -e

REPO_ROOT="/Users/ddukes/codex"
VERSION="${1:-1.0.0-custom}"

echo "Building codex-dd version $VERSION..."

# Ensure we're in the right place
cd "$REPO_ROOT"

# Build the Rust binary
echo "Step 1/3: Building Rust binary..."
cd "$REPO_ROOT/codex-rs"
. "$HOME/.cargo/env"
cargo build --release -p codex-cli

# Set up vendor directory
echo "Step 2/3: Preparing vendor directory..."
rm -rf /tmp/vendor
mkdir -p /tmp/vendor/aarch64-apple-darwin/codex
mkdir -p /tmp/vendor/aarch64-apple-darwin/path

# Copy binaries
cp "$REPO_ROOT/codex-rs/target/release/codex" /tmp/vendor/aarch64-apple-darwin/codex/
cp /opt/homebrew/bin/rg /tmp/vendor/aarch64-apple-darwin/path/

# Build npm package
echo "Step 3/3: Building npm package..."
cd "$REPO_ROOT"
rm -rf /tmp/codex-dd-stage
mkdir -p dist
python3 codex-cli/scripts/build_npm_package.py \
  --package codex \
  --version "$VERSION" \
  --vendor-src /tmp/vendor \
  --staging-dir /tmp/codex-dd-stage \
  --pack-output "dist/codex-dd-${VERSION}.tgz"

echo ""
echo "✓ Build complete!"
echo "Package: $REPO_ROOT/dist/codex-dd-${VERSION}.tgz"
echo ""
echo "To install:"
echo "  npm install -g --force dist/codex-dd-${VERSION}.tgz"
echo ""
echo "To test:"
echo "  codex-dd --version"
