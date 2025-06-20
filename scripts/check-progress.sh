#!/bin/bash

# Cerberus Chain: Hydra - Progress Checker
# Run this to check your setup progress

echo "🐺 Cerberus Chain: Hydra - Progress Check"
echo "========================================"

progress=0
total_steps=7

# Step 1: Project Structure (already done)
if [ -d "backend" ] && [ -d "frontend" ] && [ -f "README.md" ]; then
    echo "✅ Step 1: Project structure created (15%)"
    progress=$((progress + 15))
else
    echo "❌ Step 1: Project structure missing"
fi

# Step 2: Environment Configuration
if [ -f ".env" ]; then
    echo "✅ Step 2A: .env file created"
    
    # Check if critical settings are configured
    if grep -q "your_helius_api_key_here" .env; then
        echo "⚠️  Step 2B: Please configure your Helius API key in .env"
    else
        echo "✅ Step 2B: Environment configured (25%)"
        progress=$((progress + 10))
    fi
else
    echo "❌ Step 2: .env file not found"
fi

# Step 3: Dependencies
rust_deps=false
node_deps=false

if [ -f "backend/Cargo.lock" ]; then
    echo "✅ Step 3A: Rust dependencies installed"
    rust_deps=true
fi

if [ -f "frontend/node_modules/.package-lock.json" ] || [ -f "frontend/package-lock.json" ]; then
    echo "✅ Step 3B: Node.js dependencies installed"
    node_deps=true
fi

if [ "$rust_deps" = true ] && [ "$node_deps" = true ]; then
    progress=$((progress + 15))
    echo "✅ Step 3: All dependencies installed (40%)"
fi

echo ""
echo "📊 Overall Progress: ${progress}% Complete"
echo ""

if [ $progress -lt 25 ]; then
    echo "🎯 Next: Configure your .env file"
    echo "   1. Edit .env file in VS Code"
    echo "   2. Set your Helius API key"
    echo "   3. Configure other settings"
elif [ $progress -lt 40 ]; then
    echo "🎯 Next: Install dependencies"
    echo "   Run: ./scripts/setup.sh"
else
    echo "🎉 Great progress! Continue with development setup."
fi