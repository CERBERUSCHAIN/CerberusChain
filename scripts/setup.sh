#!/bin/bash

# Cerberus Chain: Hydra - Development Setup Script
# Run this from the project root: ./scripts/setup.sh

echo "🐺 Setting up Cerberus Chain: Hydra Development Environment..."

# Check prerequisites
echo "🔍 Checking prerequisites..."

# Check Rust
if command -v rustc &> /dev/null; then
    rust_version=$(rustc --version)
    echo "✅ Rust: $rust_version"
else
    echo "❌ Rust not found. Please install Rust from https://rustup.rs/"
    exit 1
fi

# Check Node.js
if command -v node &> /dev/null; then
    node_version=$(node --version)
    echo "✅ Node.js: $node_version"
else
    echo "❌ Node.js not found. Please install Node.js 18+ from https://nodejs.org/"
    exit 1
fi

# Check Docker
if command -v docker &> /dev/null; then
    docker_version=$(docker --version)
    echo "✅ Docker: $docker_version"
else
    echo "⚠️  Docker not found. Install Docker for containerized development."
fi

# Setup environment file
if [ ! -f ".env" ]; then
    echo "📄 Creating .env file from template..."
    if [ -f ".env.example" ]; then
        cp ".env.example" ".env"
        echo "✅ Created .env file. Please edit it with your configuration."
    else
        echo "⚠️  .env.example not found. Creating empty .env file."
        touch ".env"
    fi
else
    echo "✅ .env file already exists"
fi

# Install backend dependencies
echo "🦀 Installing Rust dependencies..."
if [ -d "backend" ]; then
    cd backend
    cargo check
    if [ $? -eq 0 ]; then
        echo "✅ Backend dependencies installed successfully"
    else
        echo "❌ Failed to install backend dependencies"
        cd ..
        exit 1
    fi
    cd ..
else
    echo "⚠️  Backend directory not found, skipping Rust dependencies"
fi

# Install frontend dependencies
echo "⚛️ Installing frontend dependencies..."
if [ -d "frontend" ]; then
    cd frontend
    npm install
    if [ $? -eq 0 ]; then
        echo "✅ Frontend dependencies installed successfully"
    else
        echo "❌ Failed to install frontend dependencies"
        cd ..
        exit 1
    fi
    cd ..
else
    echo "⚠️  Frontend directory not found, skipping npm install"
fi

echo ""
echo "🎉 Setup completed successfully!"
echo ""
echo "📋 Next Steps:"
echo "  1. Edit .env file with your Helius API key and other secrets"
echo "  2. Start PostgreSQL and Redis (or use Docker Compose)"
echo "  3. Run backend: cd backend && cargo run"
echo "  4. Run frontend: cd frontend && npm run dev"
echo "  5. Or use Docker: docker-compose up -d"
echo ""
echo "🚀 Ready to build the future of memecoin trading!"