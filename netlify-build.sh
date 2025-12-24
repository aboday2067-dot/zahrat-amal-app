#!/usr/bin/env bash
set -euo pipefail

# Netlify build script for Flutter web
# This script uses the Flutter SDK bundled in the repository

echo "=== Flutter Web Build for Netlify ==="

# Check if flutter-sdk exists in repo, otherwise clone it
if [ -d "flutter-sdk" ]; then
    echo "Using bundled Flutter SDK..."
else
    echo "Flutter SDK not found, cloning stable branch..."
    git clone -b stable --depth 1 https://github.com/flutter/flutter.git flutter-sdk
fi

# Add Flutter to PATH
export PATH="$PWD/flutter-sdk/bin:$PATH"

# Verify Flutter is available
echo "Flutter version:"
flutter --version

# Enable web support
echo "Enabling web support..."
flutter config --enable-web

# Pre-cache web artifacts
echo "Pre-caching web artifacts..."
flutter precache --web

# Get dependencies
echo "Getting packages..."
flutter pub get

# Build web release
echo "Building web release..."
flutter build web --release

echo "=== Build completed successfully ==="
echo "Output directory: build/web"
