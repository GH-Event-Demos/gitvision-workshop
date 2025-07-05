#!/bin/bash

# GitVision Workshop Startup Script
# This script helps participants get ready quickly

echo "🇪🇺 Welcome to GitVision Workshop! 🎵"
echo "=================================="

# Change to the correct directory
cd "$(dirname "$0")"
echo "📁 Working directory: $(pwd)"

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed. Please install Flutter first:"
    echo "   👉 https://flutter.dev/docs/get-started/install"
    exit 1
fi

echo "✅ Flutter found: $(flutter --version | head -1)"

# Check Flutter doctor
echo ""
echo "🔍 Running Flutter doctor..."
flutter doctor

# Install dependencies
echo ""
echo "📦 Installing dependencies..."
flutter pub get

# Check if API tokens file exists
if [ ! -f "lib/config/api_tokens.dart" ]; then
    echo ""
    echo "🔑 Setting up API tokens..."
    cp lib/config/api_tokens.example.dart lib/config/api_tokens.dart
    echo "✅ Created lib/config/api_tokens.dart"
    echo ""
    echo "⚠️  IMPORTANT: Edit lib/config/api_tokens.dart with your tokens:"
    echo "   📱 GitHub: https://github.com/settings/tokens"
    echo "   🎵 Spotify: https://developer.spotify.com/dashboard"
    echo ""
    echo "🔒 Your tokens are secure - this file is in .gitignore"
else
    echo "✅ API tokens file already exists"
fi

# Test the app
echo ""
echo "🧪 Testing app startup..."
if flutter run --help &> /dev/null; then
    echo "✅ Flutter app ready to run!"
    echo ""
    echo "🚀 Ready for workshop! Run:"
    echo "   flutter run"
    echo ""
    echo "📚 Check workshop/ folder for guides"
else
    echo "❌ Flutter app setup issue. Check flutter doctor output above."
    exit 1
fi

echo "🎉 Workshop setup complete! Let's build some Eurovision magic! 🇪🇺"