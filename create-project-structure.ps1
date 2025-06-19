# Cerberus Chain: Hydra - Complete Project Structure Generator
# Run this script from: C:\Users\lowke\Projects\Cerberus-Chain-Hydra
# Usage: .\create-project-structure.ps1

Write-Host "🐺 Creating Cerberus Chain: Hydra Project Structure..." -ForegroundColor Cyan
Write-Host "📁 Base Directory: $PWD" -ForegroundColor Yellow

# Ensure we're in the correct directory
$projectRoot = "C:\Users\lowke\Projects\Cerberus-Chain-Hydra"
if ($PWD.Path -ne $projectRoot) {
    Write-Host "⚠️  Changing to project directory: $projectRoot" -ForegroundColor Yellow
    Set-Location $projectRoot
}

# Create main project structure
$folders = @(
    # Root level
    ".github/workflows",
    "docs/api",
    "docs/deployment",
    "docs/architecture",
    "scripts/deployment",
    "scripts/database",
    "scripts/monitoring",
    
    # Backend (Rust)
    "backend/src/auth",
    "backend/src/api/routes",
    "backend/src/api/middleware",
    "backend/src/api/handlers",
    "backend/src/bots/volume",
    "backend/src/bots/bundle",
    "backend/src/bots/bump",
    "backend/src/bots/sniper",
    "backend/src/bots/human",
    "backend/src/bots/common",
    "backend/src/wallet",
    "backend/src/database/models",
    "backend/src/database/migrations",
    "backend/src/helius",
    "backend/src/notifications/discord",
    "backend/src/notifications/telegram",
    "backend/src/notifications/twitter",
    "backend/src/utils",
    "backend/src/config",
    "backend/tests/unit",
    "backend/tests/integration",
    "backend/migrations",
    
    # Frontend (SolidJS)
    "frontend/src/components/ui",
    "frontend/src/components/charts",
    "frontend/src/components/modals",
    "frontend/src/components/forms",
    "frontend/src/pages",
    "frontend/src/stores",
    "frontend/src/services",
    "frontend/src/utils",
    "frontend/src/types",
    "frontend/src/assets/images",
    "frontend/src/assets/icons",
    "frontend/public",
    
    # Infrastructure
    "infrastructure/docker",
    "infrastructure/nginx",
    "infrastructure/monitoring",
    "infrastructure/secrets",
    
    # Database
    "database/schemas",
    "database/seeds",
    "database/backups",
    
    # Logs and temp
    "logs",
    "temp",
    
    # Configuration
    "config/environments"
)

Write-Host "📂 Creating folder structure..." -ForegroundColor Green
foreach ($folder in $folders) {
    New-Item -ItemType Directory -Path $folder -Force | Out-Null
    Write-Host "  ✓ Created: $folder" -ForegroundColor Gray
}

# Create root level files
Write-Host "📄 Creating root configuration files..." -ForegroundColor Green

# .gitignore
@"
# Rust
/target/
**/*.rs.bk
Cargo.lock

# Environment variables
.env
.env.local
.env.production

# Database
*.db
*.sqlite

# Logs
logs/
*.log

# OS
.DS_Store
Thumbs.db

# IDE
.vscode/
.idea/
*.swp
*.swo

# Node.js (Frontend)
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*
.pnpm-debug.log*

# Frontend build
frontend/dist/
frontend/build/

# Docker
.dockerignore

# Secrets
secrets/
*.pem
*.key
id_rsa*

# Temporary files
temp/
*.tmp

# Backup files
*.bak
database/backups/*
!database/backups/.gitkeep
"@ | Out-File -FilePath ".gitignore" -Encoding UTF8

# README.md
@"
# 🐺 Cerberus Chain: Hydra

**The Three-Headed Guardian of Memecoin Trading**

A revolutionary Solana-based meme-coin trading bot built with military precision, transparency, and trust.

## 🚀 Vision

Cerberus Chain aims to redefine technological innovation in cryptocurrency trading, surpassing industry giants through superior speed, security, accuracy, and scalability.

## 🏗️ Architecture

- **Backend**: Rust with actix-web 4.5
- **Frontend**: SolidJS with Tailwind CSS
- **Database**: PostgreSQL
- **Infrastructure**: Docker + DigitalOcean
- **Blockchain**: Solana (via Helius)

## 🔥 Features

### The Three Heads of Cerberus:
1. **Strategy**: Automated entry & exit rules tailored for memes
2. **Volume**: Real-time detection of token volume spikes  
3. **Security**: On-chain rug-pull filters to protect funds

### Bot Capabilities:
- **Volume Bot**: Continuous SOL-to-token swaps
- **Bundle Bot**: Distribute SOL/tokens to wallet bundles
- **Bump Bot**: Execute periodic visibility buys
- **Sniper Bot**: Immediate token sniping within 2 slots
- **Human Mode**: Manual trading with secure JWT gating

## 🛠️ Quick Start

### Prerequisites
- Rust 1.70+
- Node.js 18+
- PostgreSQL 14+
- Docker & Docker Compose

### Development Setup

1. **Clone and setup**:
   ```bash
   cd backend
   cargo build
   ```

2. **Frontend setup**:
   ```bash
   cd frontend
   npm install
   npm run dev
   ```

3. **Database setup**:
   ```bash
   ./scripts/database/setup.sh
   ```

4. **Environment configuration**:
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

## 🔐 Security

- JWT authentication with IP allow-listing
- Encrypted wallet private keys
- Rate limiting and DDoS protection
- Military-grade security protocols

## 📊 Helius Integration

- 10M credits/month subscription
- RPC calls, WebSocket streams, Sender API
- Automatic credit monitoring (90% limit pause)
- Real-time transaction parsing

## 🚀 Deployment

### Docker Deployment
```bash
docker-compose up -d
```

### DigitalOcean Deployment
```bash
./scripts/deployment/deploy.sh
```

## 📈 Monitoring

- Prometheus & Grafana metrics
- Real-time KPI dashboards
- Multi-channel notifications (Discord, Telegram, Twitter)
- Comprehensive logging with ELK stack

## 🤝 Contributing

This is a private project. Access restricted to authorized personnel only.

## 📞 Support

For support and inquiries: support@cerberuschain.com

---

**Built by veterans, for traders. Guarding the future of memecoins.**
"@ | Out-File -FilePath "README.md" -Encoding UTF8

# Docker Compose
@"
version: '3.8'

services:
  # PostgreSQL Database
  postgres:
    image: postgres:15-alpine
    container_name: cerberus-postgres
    environment:
      POSTGRES_DB: cerberus_hydra
      POSTGRES_USER: cerberus
      POSTGRES_PASSWORD: `${POSTGRES_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./database/schemas:/docker-entrypoint-initdb.d
    ports:
      - "5432:5432"
    networks:
      - cerberus-network
    restart: unless-stopped

  # Redis Cache
  redis:
    image: redis:7-alpine
    container_name: cerberus-redis
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
    networks:
      - cerberus-network
    restart: unless-stopped

  # Backend API
  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
    container_name: cerberus-backend
    environment:
      DATABASE_URL: postgresql://cerberus:`${POSTGRES_PASSWORD}@postgres:5432/cerberus_hydra
      REDIS_URL: redis://redis:6379
      HELIUS_API_KEY: `${HELIUS_API_KEY}
      JWT_SECRET: `${JWT_SECRET}
      RUST_LOG: info
    ports:
      - "8080:8080"
    depends_on:
      - postgres
      - redis
    networks:
      - cerberus-network
    restart: unless-stopped
    volumes:
      - ./logs:/app/logs

  # Frontend
  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
    container_name: cerberus-frontend
    ports:
      - "3000:3000"
    environment:
      VITE_API_URL: http://backend:8080
    depends_on:
      - backend
    networks:
      - cerberus-network
    restart: unless-stopped

  # Nginx Reverse Proxy
  nginx:
    image: nginx:alpine
    container_name: cerberus-nginx
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./infrastructure/nginx/nginx.conf:/etc/nginx/nginx.conf
      - ./infrastructure/nginx/ssl:/etc/nginx/ssl
    depends_on:
      - frontend
      - backend
    networks:
      - cerberus-network
    restart: unless-stopped

  # Prometheus Monitoring
  prometheus:
    image: prom/prometheus:latest
    container_name: cerberus-prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./infrastructure/monitoring/prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus
    networks:
      - cerberus-network
    restart: unless-stopped

  # Grafana Dashboard
  grafana:
    image: grafana/grafana:latest
    container_name: cerberus-grafana
    ports:
      - "3001:3000"
    environment:
      GF_SECURITY_ADMIN_PASSWORD: `${GRAFANA_PASSWORD}
    volumes:
      - grafana_data:/var/lib/grafana
      - ./infrastructure/monitoring/grafana:/etc/grafana/provisioning
    networks:
      - cerberus-network
    restart: unless-stopped

volumes:
  postgres_data:
  redis_data:
  prometheus_data:
  grafana_data:

networks:
  cerberus-network:
    driver: bridge
"@ | Out-File -FilePath "docker-compose.yml" -Encoding UTF8

# Environment template
@"
# Cerberus Chain: Hydra Environment Configuration

# Database
DATABASE_URL=postgresql://cerberus:your_password@localhost:5432/cerberus_hydra
POSTGRES_PASSWORD=your_secure_postgres_password

# Redis
REDIS_URL=redis://localhost:6379

# JWT Authentication
JWT_SECRET=your_super_secure_jwt_secret_key_here
JWT_EXPIRATION_HOURS=24

# Helius Configuration
HELIUS_API_KEY=your_helius_api_key_here
HELIUS_RPC_URL=https://mainnet.helius-rpc.com/?api-key=your_helius_api_key_here
HELIUS_WEBSOCKET_URL=wss://mainnet.helius-rpc.com/?api-key=your_helius_api_key_here
HELIUS_CREDIT_LIMIT=10000000
HELIUS_CREDIT_WARNING_THRESHOLD=9000000

# Security
ALLOWED_IPS=127.0.0.1,your_ip_address_here
RATE_LIMIT_REQUESTS_PER_MINUTE=100
ENCRYPTION_KEY=your_32_character_encryption_key_here

# Solana Configuration
SOLANA_NETWORK=mainnet-beta
SOLANA_COMMITMENT=confirmed

# Wallet Configuration
MASTER_WALLET_PRIVATE_KEY=your_master_wallet_private_key_here
WALLET_STORAGE_PATH=./wallets
MAX_WALLETS_PER_GROUP=1000

# Bot Configuration
DEFAULT_SOL_AMOUNT=0.1
DEFAULT_SLIPPAGE_TOLERANCE=5.0
DEFAULT_PRIORITY_FEE=0.001

# Notifications
DISCORD_WEBHOOK_URL=https://discord.com/api/webhooks/your_webhook_here
TELEGRAM_BOT_TOKEN=your_telegram_bot_token_here
TELEGRAM_CHAT_ID=your_telegram_chat_id_here
TWITTER_API_KEY=your_twitter_api_key_here
TWITTER_API_SECRET=your_twitter_api_secret_here
TWITTER_ACCESS_TOKEN=your_twitter_access_token_here
TWITTER_ACCESS_TOKEN_SECRET=your_twitter_access_token_secret_here

# Monitoring
GRAFANA_PASSWORD=your_grafana_password_here
PROMETHEUS_RETENTION_DAYS=30

# Development
RUST_LOG=debug
RUST_BACKTRACE=1
"@ | Out-File -FilePath ".env.example" -Encoding UTF8

# Create backend Cargo.toml
Write-Host "📄 Creating backend Cargo.toml..." -ForegroundColor Green
@"
[package]
name = "cerberus-hydra-backend"
version = "0.1.0"
edition = "2021"
authors = ["Tony <tony@cerberuschain.com>", "Dave <dave@cerberuschain.com>"]
description = "Cerberus Chain: Hydra - Advanced Solana Memecoin Trading Bot Backend"

[dependencies]
# Web Framework
actix-web = "4.5"
actix-web-actors = "4.3"
actix-cors = "0.7"
actix-files = "0.6"

# Async Runtime
tokio = { version = "1.0", features = ["full"] }
futures = "0.3"

# Serialization
serde = { version = "1.0", features = ["derive"] }
serde_json = "1.0"

# Database
sqlx = { version = "0.7", features = ["runtime-tokio-rustls", "postgres", "chrono", "uuid", "json"] }

# Redis
redis = { version = "0.24", features = ["tokio-comp"] }

# Authentication & Security
jsonwebtoken = "9.2"
bcrypt = "0.15"
uuid = { version = "1.0", features = ["v4", "serde"] }

# Solana & Blockchain
solana-sdk = "1.17"
solana-client = "1.17"
solana-account-decoder = "1.17"
anchor-client = "0.29"

# HTTP Client
reqwest = { version = "0.11", features = ["json", "stream"] }

# WebSocket
tokio-tungstenite = "0.21"

# Cryptography
aes-gcm = "0.10"
rand = "0.8"
hex = "0.4"

# Configuration
dotenv = "0.15"
config = "0.14"

# Logging
log = "0.4"
env_logger = "0.11"
tracing = "0.1"
tracing-subscriber = "0.3"

# Error Handling
anyhow = "1.0"
thiserror = "1.0"

# Time
chrono = { version = "0.4", features = ["serde"] }

# Utilities
once_cell = "1.19"
lazy_static = "1.4"

# Rate Limiting
governor = "0.6"

# Metrics
prometheus = "0.13"

[dev-dependencies]
actix-rt = "2.9"
actix-test = "0.1"
"@ | Out-File -FilePath "backend/Cargo.toml" -Encoding UTF8

# Create backend main.rs
@"
//! Cerberus Chain: Hydra Backend
//! Advanced Solana Memecoin Trading Bot
//! 
//! The three-headed guardian protecting your memecoin investments
//! with military precision, transparency, and trust.

use actix_web::{web, App, HttpServer, middleware::Logger};
use dotenv::dotenv;
use std::env;

mod auth;
mod api;
mod bots;
mod wallet;
mod database;
mod helius;
mod notifications;
mod utils;
mod config;

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    // Load environment variables
    dotenv().ok();
    
    // Initialize logging
    env_logger::init();
    
    log::info!("🐺 Starting Cerberus Chain: Hydra Backend...");
    
    // Get configuration
    let bind_address = env::var("BIND_ADDRESS").unwrap_or_else(|_| "0.0.0.0:8080".to_string());
    
    log::info!("🚀 Server starting on {}", bind_address);
    
    HttpServer::new(|| {
        App::new()
            .wrap(Logger::default())
            .route("/", web::get().to(health_check))
            .service(
                web::scope("/api/v1")
                    // Authentication routes
                    .service(auth::routes())
                    // Bot control routes
                    .service(api::routes::bot_routes())
                    // Wallet management routes
                    .service(api::routes::wallet_routes())
                    // Market data routes
                    .service(api::routes::market_routes())
                    // WebSocket endpoint
                    .route("/ws", web::get().to(api::handlers::websocket::ws_handler))
            )
    })
    .bind(&bind_address)?
    .run()
    .await
}

async fn health_check() -> actix_web::Result<impl actix_web::Responder> {
    Ok(web::Json(serde_json::json!({
        "status": "healthy",
        "service": "cerberus-hydra-backend",
        "version": env!("CARGO_PKG_VERSION"),
        "timestamp": chrono::Utc::now().to_rfc3339()
    })))
}
"@ | Out-File -FilePath "backend/src/main.rs" -Encoding UTF8

# Create backend lib.rs
@"
//! Cerberus Chain: Hydra Backend Library
//! 
//! Core modules and utilities for the trading bot backend

pub mod auth;
pub mod api;
pub mod bots;
pub mod wallet;
pub mod database;
pub mod helius;
pub mod notifications;
pub mod utils;
pub mod config;

// Re-export commonly used types
pub use auth::*;
pub use config::*;
"@ | Out-File -FilePath "backend/src/lib.rs" -Encoding UTF8

# Create frontend package.json
Write-Host "📄 Creating frontend package.json..." -ForegroundColor Green
@"
{
  "name": "cerberus-hydra-frontend",
  "version": "0.1.0",
  "description": "Cerberus Chain: Hydra - Advanced Trading Bot Frontend",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview",
    "lint": "eslint src --ext .js,.jsx,.ts,.tsx",
    "lint:fix": "eslint src --ext .js,.jsx,.ts,.tsx --fix",
    "type-check": "tsc --noEmit"
  },
  "dependencies": {
    "solid-js": "^1.8.11",
    "@solidjs/router": "^0.10.5",
    "solid-heroicons": "^3.2.0",
    "@kobalte/core": "^0.12.6",
    "@tanstack/solid-query": "^5.17.1",
    "chart.js": "^4.4.1",
    "chartjs-adapter-date-fns": "^3.0.0",
    "date-fns": "^3.2.0",
    "clsx": "^2.1.0",
    "class-variance-authority": "^0.7.0"
  },
  "devDependencies": {
    "@types/node": "^20.11.5",
    "vite": "^5.0.12",
    "vite-plugin-solid": "^2.8.2",
    "typescript": "^5.3.3",
    "tailwindcss": "^3.4.1",
    "autoprefixer": "^10.4.17",
    "postcss": "^8.4.33",
    "@tailwindcss/forms": "^0.5.7",
    "@tailwindcss/typography": "^0.5.10",
    "eslint": "^8.56.0",
    "@typescript-eslint/eslint-plugin": "^6.19.1",
    "@typescript-eslint/parser": "^6.19.1",
    "eslint-plugin-solid": "^0.13.1"
  },
  "engines": {
    "node": ">=18.0.0"
  }
}
"@ | Out-File -FilePath "frontend/package.json" -Encoding UTF8

# Create frontend index.html
@"
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Cerberus Chain: Hydra - Trading Bot</title>
  <meta name="description" content="The three-headed guardian of memecoin trading" />
  <link rel="icon" type="image/svg+xml" href="/favicon.svg" />
  <link href="https://fonts.googleapis.com/css2?family=Orbitron:wght@400;700;900&family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
</head>
<body>
  <div id="root"></div>
  <script type="module" src="/src/index.tsx"></script>
</body>
</html>
"@ | Out-File -FilePath "frontend/index.html" -Encoding UTF8

# Create Dockerfiles
Write-Host "📄 Creating Docker configurations..." -ForegroundColor Green

# Backend Dockerfile
@"
FROM rust:1.75-slim as builder

WORKDIR /app

# Install dependencies
RUN apt-get update && apt-get install -y \
    pkg-config \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy manifests
COPY Cargo.toml Cargo.lock ./

# Copy source code
COPY src ./src

# Build application
RUN cargo build --release

# Runtime stage
FROM debian:bookworm-slim

WORKDIR /app

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    ca-certificates \
    libssl3 \
    && rm -rf /var/lib/apt/lists/*

# Copy binary from builder stage
COPY --from=builder /app/target/release/cerberus-hydra-backend /app/

# Create logs directory
RUN mkdir -p /app/logs

EXPOSE 8080

CMD ["./cerberus-hydra-backend"]
"@ | Out-File -FilePath "backend/Dockerfile" -Encoding UTF8

# Frontend Dockerfile
@"
FROM node:18-alpine as builder

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy source code
COPY . .

# Build application
RUN npm run build

# Runtime stage
FROM nginx:alpine

# Copy built assets
COPY --from=builder /app/dist /usr/share/nginx/html

# Copy nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 3000

CMD ["nginx", "-g", "daemon off;"]
"@ | Out-File -FilePath "frontend/Dockerfile" -Encoding UTF8

# Create GitHub Actions workflow
@"
name: Deploy Cerberus Chain Hydra

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: cerberus-chain-hydra

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    
    - name: Setup Rust
      uses: actions-rs/toolchain@v1
      with:
        toolchain: stable
        
    - name: Run backend tests
      run: |
        cd backend
        cargo test
        
    - name: Setup Node.js
      uses: actions/setup-node@v4
      with:
        node-version: '18'
        
    - name: Run frontend tests
      run: |
        cd frontend
        npm ci
        npm run lint
        npm run type-check

  build-and-deploy:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Log in to Container Registry
      uses: docker/login-action@v3
      with:
        registry: `${{ env.REGISTRY }}
        username: `${{ github.actor }}
        password: `${{ secrets.GITHUB_TOKEN }}
        
    - name: Build and push Docker images
      run: |
        docker build -t `${{ env.REGISTRY }}/`${{ github.repository }}/backend:latest ./backend
        docker build -t `${{ env.REGISTRY }}/`${{ github.repository }}/frontend:latest ./frontend
        docker push `${{ env.REGISTRY }}/`${{ github.repository }}/backend:latest
        docker push `${{ env.REGISTRY }}/`${{ github.repository }}/frontend:latest
        
    - name: Deploy to DigitalOcean
      uses: appleboy/ssh-action@v1.0.0
      with:
        host: `${{ secrets.DIGITALOCEAN_HOST }}
        username: `${{ secrets.DIGITALOCEAN_USERNAME }}
        key: `${{ secrets.DIGITALOCEAN_SSH_KEY }}
        script: |
          cd /opt/cerberus-hydra
          docker-compose pull
          docker-compose up -d
          docker system prune -f
"@ | Out-File -FilePath ".github/workflows/deploy.yml" -Encoding UTF8

# Create deployment scripts
Write-Host "📄 Creating deployment scripts..." -ForegroundColor Green

@"
#!/bin/bash
# Cerberus Chain: Hydra Deployment Script

set -e

echo "🐺 Deploying Cerberus Chain: Hydra..."

# Build Docker images
echo "🔨 Building Docker images..."
docker-compose build

# Start services
echo "🚀 Starting services..."
docker-compose up -d

# Wait for services to be ready
echo "⏳ Waiting for services to be ready..."
sleep 30

# Run database migrations
echo "📊 Running database migrations..."
docker-compose exec backend ./scripts/run-migrations.sh

# Health check
echo "🏥 Performing health check..."
curl -f http://localhost:8080/ || exit 1

echo "✅ Deployment completed successfully!"
echo "🌐 Frontend: http://localhost:3000"
echo "🔧 Backend API: http://localhost:8080"
echo "📊 Grafana: http://localhost:3001"
echo "📈 Prometheus: http://localhost:9090"
"@ | Out-File -FilePath "scripts/deployment/deploy.sh" -Encoding UTF8

# Create database setup script
@"
#!/bin/bash
# Database Setup Script

set -e

echo "📊 Setting up Cerberus Chain: Hydra Database..."

# Create database if it doesn't exist
createdb cerberus_hydra || echo "Database already exists"

# Run migrations
echo "🔄 Running migrations..."
sqlx migrate run --database-url `$DATABASE_URL

echo "✅ Database setup completed!"
"@ | Out-File -FilePath "scripts/database/setup.sh" -Encoding UTF8

# Create monitoring configuration
@"
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  # - "first_rules.yml"
  # - "second_rules.yml"

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'cerberus-backend'
    static_configs:
      - targets: ['backend:8080']
    metrics_path: '/metrics'
    scrape_interval: 5s

  - job_name: 'postgres'
    static_configs:
      - targets: ['postgres:5432']

  - job_name: 'redis'
    static_configs:
      - targets: ['redis:6379']
"@ | Out-File -FilePath "infrastructure/monitoring/prometheus.yml" -Encoding UTF8

# Create nginx configuration
@"
events {
    worker_connections 1024;
}

http {
    upstream backend {
        server backend:8080;
    }

    upstream frontend {
        server frontend:3000;
    }

    server {
        listen 80;
        server_name localhost;

        # Frontend
        location / {
            proxy_pass http://frontend;
            proxy_set_header Host `$host;
            proxy_set_header X-Real-IP `$remote_addr;
            proxy_set_header X-Forwarded-For `$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto `$scheme;
        }

        # Backend API
        location /api/ {
            proxy_pass http://backend;
            proxy_set_header Host `$host;
            proxy_set_header X-Real-IP `$remote_addr;
            proxy_set_header X-Forwarded-For `$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto `$scheme;
        }

        # WebSocket
        location /ws {
            proxy_pass http://backend;
            proxy_http_version 1.1;
            proxy_set_header Upgrade `$http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_set_header Host `$host;
            proxy_set_header X-Real-IP `$remote_addr;
            proxy_set_header X-Forwarded-For `$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto `$scheme;
        }
    }
}
"@ | Out-File -FilePath "infrastructure/nginx/nginx.conf" -Encoding UTF8

# Create placeholder files to ensure directories are tracked
$placeholderFiles = @(
    "backend/src/auth/mod.rs",
    "backend/src/api/mod.rs",
    "backend/src/bots/mod.rs",
    "backend/src/wallet/mod.rs",
    "backend/src/database/mod.rs",
    "backend/src/helius/mod.rs",
    "backend/src/notifications/mod.rs",
    "backend/src/utils/mod.rs",
    "backend/src/config/mod.rs",
    "frontend/src/index.tsx",
    "frontend/src/App.tsx",
    "database/backups/.gitkeep",
    "logs/.gitkeep",
    "temp/.gitkeep"
)

Write-Host "📄 Creating placeholder files..." -ForegroundColor Green
foreach ($file in $placeholderFiles) {
    if ($file.EndsWith(".gitkeep")) {
        "" | Out-File -FilePath $file -Encoding UTF8
    } elseif ($file.EndsWith(".rs")) {
        "// TODO: Implement module" | Out-File -FilePath $file -Encoding UTF8
    } elseif ($file.EndsWith(".tsx")) {
        "// TODO: Implement component" | Out-File -FilePath $file -Encoding UTF8
    }
    Write-Host "  ✓ Created: $file" -ForegroundColor Gray
}

# Create VS Code workspace settings
Write-Host "📄 Creating VS Code workspace configuration..." -ForegroundColor Green
New-Item -ItemType Directory -Path ".vscode" -Force | Out-Null

@"
{
    "folders": [
        {
            "name": "🐺 Cerberus Chain: Hydra",
            "path": "."
        },
        {
            "name": "🦀 Backend (Rust)",
            "path": "./backend"
        },
        {
            "name": "⚡ Frontend (SolidJS)",
            "path": "./frontend"
        }
    ],
    "settings": {
        "rust-analyzer.linkedProjects": ["./backend/Cargo.toml"],
        "typescript.preferences.importModuleSpecifier": "relative",
        "editor.formatOnSave": true,
        "editor.codeActionsOnSave": {
            "source.fixAll.eslint": true
        }
    },
    "extensions": {
        "recommendations": [
            "rust-lang.rust-analyzer",
            "bradlc.vscode-tailwindcss",
            "ms-vscode.vscode-typescript-next",
            "esbenp.prettier-vscode",
            "ms-vscode.vscode-json"
        ]
    }
}
"@ | Out-File -FilePath "cerberus-hydra.code-workspace" -Encoding UTF8

Write-Host ""
Write-Host "🎉 Project structure created successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Next Steps:" -ForegroundColor Yellow
Write-Host "  1. Copy .env.example to .env and configure your settings" -ForegroundColor White
Write-Host "  2. Open the workspace in VS Code: code cerberus-hydra.code-workspace" -ForegroundColor White
Write-Host "  3. Install Rust dependencies: cd backend && cargo build" -ForegroundColor White
Write-Host "  4. Install Node.js dependencies: cd frontend && npm install" -ForegroundColor White
Write-Host "  5. Set up your PostgreSQL database" -ForegroundColor White
Write-Host "  6. Configure your Helius API key and other secrets" -ForegroundColor White
Write-Host ""
Write-Host "🚀 Ready to build the future of memecoin trading!" -ForegroundColor Cyan
Write-Host "🐺 Cerberus Chain: Hydra - Guarding your investments with military precision" -ForegroundColor Magenta