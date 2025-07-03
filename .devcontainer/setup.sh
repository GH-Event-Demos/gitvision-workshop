#!/bin/bash
set -e

echo "🇪🇺 Setting up GitVision Workshop Environment..."

# Install required dependencies
echo "📦 Installing system dependencies..."
sudo apt-get update && sudo apt-get install -y curl git wget unzip xz-utils libglu1-mesa

# Download and install Flutter with specific version
echo "📱 Installing Flutter SDK..."
FLUTTER_VERSION="3.32.5"  # Using newer version to support flutter_lints ^6.0.0
wget -O flutter.tar.xz "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"
sudo tar xf flutter.tar.xz -C /opt
rm flutter.tar.xz

# Set proper ownership
sudo chown -R vscode:vscode /opt/flutter

# Add Flutter to PATH and make it persist
echo 'export PATH="/opt/flutter/bin:$PATH"' >> ~/.bashrc
export PATH="/opt/flutter/bin:$PATH"

# Preconfigure Flutter to use right channel
flutter channel stable
flutter config --no-analytics

# Navigate to project directory
cd /workspaces/$(basename $PWD)/gitvision

# Disable Android SDK checks for now since we don't need them for initial setup
export FLUTTER_SDK_SKIP_ANDROID_CHECK=true

# Get Flutter dependencies
echo "📦 Installing Flutter dependencies..."
flutter pub get

# Make workshop script executable
chmod +x workshop-start.sh

echo "✅ GitVision setup complete! Ready for workshop."
echo "💡 Flutter version installed: $(flutter --version)"
echo "🎵 Run './workshop-start.sh' to begin!"
echo "🌐 Then run 'flutter run -d web-server' to start the app in your browser."
