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

# Function to create files with content
function Create-FileWithContent {
    param(
        [string]$FilePath,
        [string[]]$Content
    )
    
    $Content | Out-File -FilePath $FilePath -Encoding UTF8
    Write-Host "  ✓ Created: $FilePath" -ForegroundColor Gray
}

Write-Host "📄 Creating root configuration files..." -ForegroundColor Green

# .gitignore
$gitignoreLines = @(
    "# Rust",
    "/target/",
    "**/*.rs.bk",
    "Cargo.lock",
    "",
    "# Environment variables",
    ".env",
    ".env.local",
    ".env.production",
    "",
    "# Database",
    "*.db",
    "*.sqlite",
    "",
    "# Logs",
    "logs/",
    "*.log",
    "",
    "# OS",
    ".DS_Store",
    "Thumbs.db",
    "",
    "# IDE",
    ".vscode/",
    ".idea/",
    "*.swp",
    "*.swo",
    "",
    "# Node.js (Frontend)",
    "node_modules/",
    "npm-debug.log*",
    "yarn-debug.log*",
    "yarn-error.log*",
    ".pnpm-debug.log*",
    "",
    "# Frontend build",
    "frontend/dist/",
    "frontend/build/",
    "",
    "# Docker",
    ".dockerignore",
    "",
    "# Secrets",
    "secrets/",
    "*.pem",
    "*.key",
    "id_rsa*",
    "",
    "# Temporary files",
    "temp/",
    "*.tmp",
    "",
    "# Backup files",
    "*.bak",
    "database/backups/*",
    "!database/backups/.gitkeep"
)

Create-FileWithContent -FilePath ".gitignore" -Content $gitignoreLines

# README.md
$readmeLines = @(
    "# Cerberus Chain: Hydra",
    "",
    "The Three-Headed Guardian of Memecoin Trading",
    "",
    "A revolutionary Solana-based meme-coin trading bot built with military precision, transparency, and trust.",
    "",
    "## Vision",
    "",
    "Cerberus Chain aims to redefine technological innovation in cryptocurrency trading, surpassing industry giants through superior speed, security, accuracy, and scalability.",
    "",
    "## Architecture",
    "",
    "Technology Stack:",
    "- Backend: Rust with actix-web 4.5",
    "- Frontend: SolidJS with Tailwind CSS",
    "- Database: PostgreSQL",
    "- Infrastructure: Docker and DigitalOcean",
    "- Blockchain: Solana via Helius",
    "",
    "## Features",
    "",
    "### The Three Heads of Cerberus:",
    "1. Strategy: Automated entry and exit rules tailored for memes",
    "2. Volume: Real-time detection of token volume spikes",
    "3. Security: On-chain rug-pull filters to protect funds",
    "",
    "### Bot Capabilities:",
    "- Volume Bot: Continuous SOL-to-token swaps",
    "- Bundle Bot: Distribute SOL/tokens to wallet bundles",
    "- Bump Bot: Execute periodic visibility buys",
    "- Sniper Bot: Immediate token sniping within 2 slots",
    "- Human Mode: Manual trading with secure JWT gating",
    "",
    "## Quick Start",
    "",
    "### Prerequisites",
    "- Rust 1.70+",
    "- Node.js 18+",
    "- PostgreSQL 14+",
    "- Docker and Docker Compose",
    "",
    "### Development Setup",
    "",
    "1. Clone and setup:",
    "   ```bash",
    "   cd backend",
    "   cargo build",
    "   ```",
    "",
    "2. Frontend setup:",
    "   ```bash",
    "   cd frontend",
    "   npm install",
    "   npm run dev",
    "   ```",
    "",
    "3. Database setup:",
    "   ```bash",
    "   ./scripts/database/setup.sh",
    "   ```",
    "",
    "4. Environment configuration:",
    "   ```bash",
    "   cp .env.example .env",
    "   # Edit .env with your configuration",
    "   ```",
    "",
    "## Security",
    "",
    "- JWT authentication with IP allow-listing",
    "- Encrypted wallet private keys",
    "- Rate limiting and DDoS protection",
    "- Military-grade security protocols",
    "",
    "## Helius Integration",
    "",
    "- 10M credits/month subscription",
    "- RPC calls, WebSocket streams, Sender API",
    "- Automatic credit monitoring (90 percent limit pause)",
    "- Real-time transaction parsing",
    "",
    "## Deployment",
    "",
    "### Docker Deployment",
    "```bash",
    "docker-compose up -d",
    "```",
    "",
    "### DigitalOcean Deployment",
    "```bash",
    "./scripts/deployment/deploy.sh",
    "```",
    "",
    "## Monitoring",
    "",
    "- Prometheus and Grafana metrics",
    "- Real-time KPI dashboards",
    "- Multi-channel notifications (Discord, Telegram, Twitter)",
    "- Comprehensive logging with ELK stack",
    "",
    "## Contributing",
    "",
    "This is a private project. Access restricted to authorized personnel only.",
    "",
    "## Support",
    "",
    "For support and inquiries: support@cerberuschain.com",
    "",
    "Built by veterans, for traders. Guarding the future of memecoins."
)

Create-FileWithContent -FilePath "README.md" -Content $readmeLines

# Docker Compose
$dockerComposeLines = @(
    "version: '3.8'",
    "",
    "services:",
    "  postgres:",
    "    image: postgres:15-alpine",
    "    container_name: cerberus-postgres",
    "    environment:",
    "      POSTGRES_DB: cerberus_hydra",
    "      POSTGRES_USER: cerberus",
    "      POSTGRES_PASSWORD: secure_password_here",
    "    volumes:",
    "      - postgres_data:/var/lib/postgresql/data",
    "      - ./database/schemas:/docker-entrypoint-initdb.d",
    "    ports:",
    '      - "5432:5432"',
    "    networks:",
    "      - cerberus-network",
    "    restart: unless-stopped",
    "",
    "  redis:",
    "    image: redis:7-alpine",
    "    container_name: cerberus-redis",
    "    ports:",
    '      - "6379:6379"',
    "    volumes:",
    "      - redis_data:/data",
    "    networks:",
    "      - cerberus-network",
    "    restart: unless-stopped",
    "",
    "  backend:",
    "    build:",
    "      context: ./backend",
    "      dockerfile: Dockerfile",
    "    container_name: cerberus-backend",
    "    environment:",
    "      DATABASE_URL: postgresql://cerberus:secure_password_here@postgres:5432/cerberus_hydra",
    "      REDIS_URL: redis://redis:6379",
    "      HELIUS_API_KEY: your_helius_api_key_here",
    "      JWT_SECRET: your_jwt_secret_here",
    "      RUST_LOG: info",
    "    ports:",
    '      - "8080:8080"',
    "    depends_on:",
    "      - postgres",
    "      - redis",
    "    networks:",
    "      - cerberus-network",
    "    restart: unless-stopped",
    "    volumes:",
    "      - ./logs:/app/logs",
    "",
    "  frontend:",
    "    build:",
    "      context: ./frontend",
    "      dockerfile: Dockerfile",
    "    container_name: cerberus-frontend",
    "    ports:",
    '      - "3000:3000"',
    "    environment:",
    "      VITE_API_URL: http://backend:8080",
    "    depends_on:",
    "      - backend",
    "    networks:",
    "      - cerberus-network",
    "    restart: unless-stopped",
    "",
    "volumes:",
    "  postgres_data:",
    "  redis_data:",
    "",
    "networks:",
    "  cerberus-network:",
    "    driver: bridge"
)

Create-FileWithContent -FilePath "docker-compose.yml" -Content $dockerComposeLines

# Environment template
$envLines = @(
    "# Cerberus Chain: Hydra Environment Configuration",
    "",
    "# Database",
    "DATABASE_URL=postgresql://cerberus:your_password@localhost:5432/cerberus_hydra",
    "POSTGRES_PASSWORD=your_secure_postgres_password",
    "",
    "# Redis",
    "REDIS_URL=redis://localhost:6379",
    "",
    "# JWT Authentication",
    "JWT_SECRET=your_super_secure_jwt_secret_key_here",
    "JWT_EXPIRATION_HOURS=24",
    "",
    "# Helius Configuration",
    "HELIUS_API_KEY=your_helius_api_key_here",
    "HELIUS_RPC_URL=https://mainnet.helius-rpc.com/?api-key=your_helius_api_key_here",
    "HELIUS_WEBSOCKET_URL=wss://mainnet.helius-rpc.com/?api-key=your_helius_api_key_here",
    "HELIUS_CREDIT_LIMIT=10000000",
    "HELIUS_CREDIT_WARNING_THRESHOLD=9000000",
    "",
    "# Security",
    "ALLOWED_IPS=127.0.0.1,your_ip_address_here",
    "RATE_LIMIT_REQUESTS_PER_MINUTE=100",
    "ENCRYPTION_KEY=your_32_character_encryption_key_here",
    "",
    "# Solana Configuration",
    "SOLANA_NETWORK=mainnet-beta",
    "SOLANA_COMMITMENT=confirmed",
    "",
    "# Wallet Configuration",
    "MASTER_WALLET_PRIVATE_KEY=your_master_wallet_private_key_here",
    "WALLET_STORAGE_PATH=./wallets",
    "MAX_WALLETS_PER_GROUP=1000",
    "",
    "# Bot Configuration",
    "DEFAULT_SOL_AMOUNT=0.1",
    "DEFAULT_SLIPPAGE_TOLERANCE=5.0",
    "DEFAULT_PRIORITY_FEE=0.001",
    "",
    "# Notifications",
    "DISCORD_WEBHOOK_URL=https://discord.com/api/webhooks/your_webhook_here",
    "TELEGRAM_BOT_TOKEN=your_telegram_bot_token_here",
    "TELEGRAM_CHAT_ID=your_telegram_chat_id_here",
    "",
    "# Monitoring",
    "GRAFANA_PASSWORD=your_grafana_password_here",
    "PROMETHEUS_RETENTION_DAYS=30",
    "",
    "# Development",
    "RUST_LOG=debug",
    "RUST_BACKTRACE=1"
)

Create-FileWithContent -FilePath ".env.example" -Content $envLines

# Create backend Cargo.toml
Write-Host "📄 Creating backend Cargo.toml..." -ForegroundColor Green
$cargoLines = @(
    "[package]",
    'name = "cerberus-hydra-backend"',
    'version = "0.1.0"',
    'edition = "2021"',
    'authors = ["Tony <tony@cerberuschain.com>", "Dave <dave@cerberuschain.com>"]',
    'description = "Cerberus Chain: Hydra - Advanced Solana Memecoin Trading Bot Backend"',
    "",
    "[dependencies]",
    'actix-web = "4.5"',
    'actix-web-actors = "4.3"',
    'actix-cors = "0.7"',
    'actix-files = "0.6"',
    'tokio = { version = "1.0", features = ["full"] }',
    'futures = "0.3"',
    'serde = { version = "1.0", features = ["derive"] }',
    'serde_json = "1.0"',
    'sqlx = { version = "0.7", features = ["runtime-tokio-rustls", "postgres", "chrono", "uuid", "json"] }',
    'redis = { version = "0.24", features = ["tokio-comp"] }',
    'jsonwebtoken = "9.2"',
    'bcrypt = "0.15"',
    'uuid = { version = "1.0", features = ["v4", "serde"] }',
    'solana-sdk = "1.17"',
    'solana-client = "1.17"',
    'solana-account-decoder = "1.17"',
    'anchor-client = "0.29"',
    'reqwest = { version = "0.11", features = ["json", "stream"] }',
    'tokio-tungstenite = "0.21"',
    'aes-gcm = "0.10"',
    'rand = "0.8"',
    'hex = "0.4"',
    'dotenv = "0.15"',
    'config = "0.14"',
    'log = "0.4"',
    'env_logger = "0.11"',
    'tracing = "0.1"',
    'tracing-subscriber = "0.3"',
    'anyhow = "1.0"',
    'thiserror = "1.0"',
    'chrono = { version = "0.4", features = ["serde"] }',
    'once_cell = "1.19"',
    'lazy_static = "1.4"',
    'governor = "0.6"',
    'prometheus = "0.13"',
    "",
    "[dev-dependencies]",
    'actix-rt = "2.9"',
    'actix-test = "0.1"'
)

Create-FileWithContent -FilePath "backend/Cargo.toml" -Content $cargoLines

# Create backend main.rs
$mainRsLines = @(
    "//! Cerberus Chain: Hydra Backend",
    "//! Advanced Solana Memecoin Trading Bot",
    "//! ",
    "//! The three-headed guardian protecting your memecoin investments",
    "//! with military precision, transparency, and trust.",
    "",
    "use actix_web::{web, App, HttpServer, middleware::Logger};",
    "use dotenv::dotenv;",
    "use std::env;",
    "",
    "mod auth;",
    "mod api;",
    "mod bots;",
    "mod wallet;",
    "mod database;",
    "mod helius;",
    "mod notifications;",
    "mod utils;",
    "mod config;",
    "",
    "#[actix_web::main]",
    "async fn main() -> std::io::Result<()> {",
    "    dotenv().ok();",
    "    env_logger::init();",
    "    ",
    '    log::info!("🐺 Starting Cerberus Chain: Hydra Backend...");',
    "    ",
    '    let bind_address = env::var("BIND_ADDRESS").unwrap_or_else(|_| "0.0.0.0:8080".to_string());',
    "    ",
    '    log::info!("🚀 Server starting on {}", bind_address);',
    "    ",
    "    HttpServer::new(|| {",
    "        App::new()",
    "            .wrap(Logger::default())",
    '            .route("/", web::get().to(health_check))',
    "    })",
    "    .bind(&bind_address)?",
    "    .run()",
    "    .await",
    "}",
    "",
    "async fn health_check() -> actix_web::Result<impl actix_web::Responder> {",
    "    Ok(web::Json(serde_json::json!({",
    '        "status": "healthy",',
    '        "service": "cerberus-hydra-backend",',
    '        "version": env!("CARGO_PKG_VERSION"),',
    '        "timestamp": chrono::Utc::now().to_rfc3339()',
    "    })))",
    "}"
)

Create-FileWithContent -FilePath "backend/src/main.rs" -Content $mainRsLines

# Create frontend package.json
Write-Host "📄 Creating frontend package.json..." -ForegroundColor Green
$packageJsonLines = @(
    "{",
    '  "name": "cerberus-hydra-frontend",',
    '  "version": "0.1.0",',
    '  "description": "Cerberus Chain: Hydra - Advanced Trading Bot Frontend",',
    '  "type": "module",',
    '  "scripts": {',
    '    "dev": "vite",',
    '    "build": "vite build",',
    '    "preview": "vite preview",',
    '    "lint": "eslint src --ext .js,.jsx,.ts,.tsx",',
    '    "lint:fix": "eslint src --ext .js,.jsx,.ts,.tsx --fix",',
    '    "type-check": "tsc --noEmit"',
    "  },",
    '  "dependencies": {',
    '    "solid-js": "^1.8.11",',
    '    "@solidjs/router": "^0.10.5",',
    '    "solid-heroicons": "^3.2.0",',
    '    "@kobalte/core": "^0.12.6",',
    '    "@tanstack/solid-query": "^5.17.1",',
    '    "chart.js": "^4.4.1",',
    '    "chartjs-adapter-date-fns": "^3.0.0",',
    '    "date-fns": "^3.2.0",',
    '    "clsx": "^2.1.0",',
    '    "class-variance-authority": "^0.7.0"',
    "  },",
    '  "devDependencies": {',
    '    "@types/node": "^20.11.5",',
    '    "vite": "^5.0.12",',
    '    "vite-plugin-solid": "^2.8.2",',
    '    "typescript": "^5.3.3",',
    '    "tailwindcss": "^3.4.1",',
    '    "autoprefixer": "^10.4.17",',
    '    "postcss": "^8.4.33",',
    '    "@tailwindcss/forms": "^0.5.7",',
    '    "@tailwindcss/typography": "^0.5.10",',
    '    "eslint": "^8.56.0",',
    '    "@typescript-eslint/eslint-plugin": "^6.19.1",',
    '    "@typescript-eslint/parser": "^6.19.1",',
    '    "eslint-plugin-solid": "^0.13.1"',
    "  },",
    '  "engines": {',
    '    "node": ">=18.0.0"',
    "  }",
    "}"
)

Create-FileWithContent -FilePath "frontend/package.json" -Content $packageJsonLines

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

Write-Host ""
Write-Host "🎉 Project structure created successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Next Steps:" -ForegroundColor Yellow
Write-Host "  1. Copy .env.example to .env and configure your settings" -ForegroundColor White
Write-Host "  2. Install Rust dependencies: cd backend && cargo build" -ForegroundColor White
Write-Host "  3. Install Node.js dependencies: cd frontend && npm install" -ForegroundColor White
Write-Host "  4. Set up your PostgreSQL database" -ForegroundColor White
Write-Host "  5. Configure your Helius API key and other secrets" -ForegroundColor White
Write-Host ""
Write-Host "🚀 Ready to build the future of memecoin trading!" -ForegroundColor Cyan
Write-Host "🐺 Cerberus Chain: Hydra - Guarding your investments with military precision" -ForegroundColor Magenta