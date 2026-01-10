#!/bin/bash
# Build and package the VS Code extension

set -e

echo "🔨 Building Xcode File Manager Extension..."

# Check Node.js version
NODE_VERSION=$(node -v | cut -d'v' -f2)
REQUIRED_VERSION="20.0.0"

version_compare() {
  printf '%s\n%s\n' "$2" "$1" | sort -V -C
}

if ! version_compare "$NODE_VERSION" "$REQUIRED_VERSION"; then
  echo "❌ Error: Node.js version $NODE_VERSION is too old."
  echo "   @vscode/vsce requires Node.js >= 20.0.0"
  echo ""
  echo "Please upgrade Node.js using one of these methods:"
  echo ""
  echo "1. Using Homebrew (recommended):"
  echo "   brew install node"
  echo ""
  echo "2. Using nvm (Node Version Manager):"
  echo "   curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash"
  echo "   nvm install 20"
  echo "   nvm use 20"
  echo ""
  echo "3. Download from official website:"
  echo "   https://nodejs.org/"
  echo ""
  echo "After upgrading, run this script again."
  echo ""
  echo "Current Node.js path: $(which node)"
  exit 1
fi

# Install dependencies if needed
if [ ! -d "node_modules" ]; then
  echo "📦 Installing dependencies..."
  npm install
fi

# Compile TypeScript
echo "🔄 Compiling TypeScript..."
npm run compile

# Check if @vscode/vsce is installed
if ! command -v vsce &> /dev/null; then
  echo "📥 Installing @vscode/vsce globally..."
  npm install -g @vscode/vsce
fi

# Package the extension
echo "📦 Packaging extension..."
vsce package

echo "✅ Done! Extension packaged successfully."
echo ""
echo "To install the extension:"
echo "1. Open VS Code"
echo "2. Go to Extensions (Cmd+Shift+X)"
echo "3. Click '...' menu → Install from VSIX..."
echo "4. Select the .vsix file created in this directory"
