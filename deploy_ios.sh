#!/bin/bash

# Solatify iOS Deployment Script
# Deploy to iPhone 16 Pro

echo "🚀 Starting Solatify iOS Deployment..."
echo "=================================="

# Step 1: Clean Build
echo "📦 Step 1: Cleaning build..."
flutter clean
flutter pub get

# Step 2: Get iOS dependencies
echo "📚 Step 2: Installing iOS dependencies..."
cd ios
pod install --repo-update
cd ..

# Step 3: List connected devices
echo "📱 Step 3: Connected devices:"
flutter devices

# Step 4: Build for iOS Release
echo "🔨 Step 4: Building iOS Release..."
flutter build ios --release

# Step 5: Deploy to device
echo "📲 Step 5: Deploying to iPhone 16 Pro..."
echo "Select device ID from list above and run:"
echo "flutter run --release -d <DEVICE_ID>"

echo ""
echo "✅ Build complete! Ready for deployment."
echo "=================================="
