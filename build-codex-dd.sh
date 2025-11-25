#!/bin/bash
# Build and package codex-dd with local changes

set -e

REPO_ROOT="/Users/ddukes/codex"

# Auto-increment build number if VERSION not provided
if [ -z "$1" ]; then
  # Find the latest build number from existing packages
  LATEST=$(ls -1 "$REPO_ROOT/dist"/codex-dd-1.0.0-custom.*.tgz 2>/dev/null | \
    sed -n 's/.*codex-dd-1.0.0-custom\.\([0-9]*\)\.tgz/\1/p' | \
    sort -n | tail -1)
  
  if [ -z "$LATEST" ]; then
    BUILD_NUM=1
  else
    BUILD_NUM=$((LATEST + 1))
  fi
  
  VERSION="1.0.0-custom.${BUILD_NUM}"
  echo "Auto-incremented to build $BUILD_NUM"
else
  VERSION="$1"
fi

echo "Building codex-dd version $VERSION..."

# Ensure we're in the right place
cd "$REPO_ROOT"

# Update workspace version in Cargo.toml
echo "Step 1/4: Updating workspace version to $VERSION..."
cd "$REPO_ROOT/codex-rs"
sed -i.bak "s/^version = \".*\"/version = \"$VERSION\"/" Cargo.toml

# Build the Rust binary
echo "Step 2/4: Building Rust binary..."
. "$HOME/.cargo/env"
cargo build --release -p codex-cli

# Restore original Cargo.toml
mv Cargo.toml.bak Cargo.toml

# Set up vendor directory
echo "Step 3/4: Preparing vendor directory..."
rm -rf /tmp/vendor
mkdir -p /tmp/vendor/aarch64-apple-darwin/codex
mkdir -p /tmp/vendor/aarch64-apple-darwin/path

# Copy binaries
cp "$REPO_ROOT/codex-rs/target/release/codex" /tmp/vendor/aarch64-apple-darwin/codex/
cp /opt/homebrew/bin/rg /tmp/vendor/aarch64-apple-darwin/path/

# Build npm package
echo "Step 4/4: Building npm package..."
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
