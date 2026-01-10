#!/bin/bash
# Quick setup script for Xcode File Manager Extension

echo "🚀 Xcode File Manager Extension - Quick Setup"
echo "=============================================="
echo ""

# Check Ruby
echo "1️⃣ Checking Ruby..."
if command -v ruby &> /dev/null; then
    RUBY_VERSION=$(ruby -v)
    echo "   ✅ Ruby found: $RUBY_VERSION"
else
    echo "   ❌ Ruby not found!"
    echo "   Install with: brew install ruby"
    exit 1
fi

# Check xcodeproj gem
echo ""
echo "2️⃣ Checking xcodeproj gem..."
if gem list xcodeproj -i &> /dev/null; then
    echo "   ✅ xcodeproj gem installed"
else
    echo "   ⚠️  xcodeproj gem not found"
    echo "   Installing xcodeproj gem..."
    gem install xcodeproj
    if [ $? -eq 0 ]; then
        echo "   ✅ xcodeproj gem installed successfully"
    else
        echo "   ❌ Failed to install xcodeproj gem"
        exit 1
    fi
fi

# Check Node.js
echo ""
echo "3️⃣ Checking Node.js..."
if command -v node &> /dev/null; then
    NODE_VERSION=$(node -v)
    echo "   ✅ Node.js found: $NODE_VERSION"
else
    echo "   ❌ Node.js not found!"
    echo "   Install from: https://nodejs.org/"
    exit 1
fi

# Install dependencies
echo ""
echo "4️⃣ Installing npm dependencies..."
if [ ! -d "node_modules" ]; then
    npm install
    if [ $? -eq 0 ]; then
        echo "   ✅ Dependencies installed"
    else
        echo "   ❌ Failed to install dependencies"
        exit 1
    fi
else
    echo "   ✅ Dependencies already installed"
fi

# Compile
echo ""
echo "5️⃣ Compiling TypeScript..."
npm run compile
if [ $? -eq 0 ]; then
    echo "   ✅ Compilation successful"
else
    echo "   ❌ Compilation failed"
    exit 1
fi

# Make scripts executable
echo ""
echo "6️⃣ Setting permissions..."
chmod +x src/scripts/*.rb
chmod +x build.sh
echo "   ✅ Permissions set"

echo ""
echo "=============================================="
echo "🎉 Setup Complete!"
echo ""
echo "Next steps:"
echo "  1. Press F5 in VS Code to start debugging"
echo "  2. Or run './build.sh' to create a .vsix package"
echo "  3. Read QUICKSTART.md for usage examples"
echo ""
echo "Happy coding! 🚀"
