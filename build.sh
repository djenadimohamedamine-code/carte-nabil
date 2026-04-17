#!/bin/bash

# Configuration for Flutter on Vercel
echo "🚀 Starting Flutter Web Build..."

# Step 1: Clone Flutter (using a shallower clone to save time/space)
if [ ! -d "flutter" ]; then
    echo "📦 Cloning Flutter SDK..."
    git clone --depth 1 https://github.com/flutter/flutter.git -b stable
fi

export PATH="$PATH:`pwd`/flutter/bin"

# Step 2: Configure and Build
echo "⚙️ Configuring Flutter..."
flutter config --enable-web

echo "📥 Getting dependencies..."
flutter pub get

echo "🏗️ Building Web App..."
# Force build web even if folder was missing (redundant now but safe)
flutter build web --release

echo "✅ Build Complete! Output is in build/web"
