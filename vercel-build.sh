#!/bin/bash

# Exit script if any command fails
set -e

echo "=== System Info ==="
uname -a

echo "=== Cloning Flutter SDK (Stable Channel) ==="
# Clone the stable branch of Flutter with depth 1 for faster download
git clone https://github.com/flutter/flutter.git -b stable --depth 1

# Add Flutter to the path
export PATH="$PATH:$PWD/flutter/bin"

echo "=== Verifying Installation ==="
flutter doctor

echo "=== Building Flutter Web Release ==="
flutter build web --release

echo "=== Build Complete ==="
