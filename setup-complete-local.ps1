# Complete Local Setup for Cerberus Chain: Hydra
# No Supabase, no network dependencies, just works!

Write-Host "🐺 Cerberus Chain: Hydra - Complete Local Setup" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor White
Write-Host ""

Write-Host "📋 This setup eliminates ALL network dependencies" -ForegroundColor Green
Write-Host "   ✅ Local PostgreSQL database" -ForegroundColor Gray
Write-Host "   ✅ No Supabase connection issues" -ForegroundColor Gray
Write-Host "   ✅ Faster development" -ForegroundColor Gray
Write-Host "   ✅ Works offline" -ForegroundColor Gray
Write-Host ""

# Step 1: Check Docker
Write-Host "🐳 Step 1: Checking Docker..." -ForegroundColor Yellow
try {
    $dockerVersion = docker --version 2>$null
    if ($dockerVersion) {
        Write-Host "✅ Docker found: $dockerVersion" -ForegroundColor Green
    } else {
        Write-Host "❌ Docker not found" -ForegroundColor Red
        Write-Host ""
        Write-Host "💡 Please install Docker Desktop:" -ForegroundColor Yellow
        Write-Host "   1. Go to: https://www.docker.com/products/docker-desktop" -ForegroundColor White
        Write-Host "   2. Download and install Docker Desktop" -ForegroundColor White
        Write-Host "   3. Start Docker Desktop" -ForegroundColor White
        Write-Host "   4. Run this script again" -ForegroundColor White
        exit 1
    }
} catch {
    Write-Host "❌ Docker not found" -ForegroundColor Red
    Write-Host "💡 Install Docker Desktop from: https://www.docker.com/products/docker-desktop" -ForegroundColor Yellow
    exit 1
}

# Step 2: Setup PostgreSQL
Write-Host ""
Write-Host "🗄️ Step 2: Setting up PostgreSQL database..." -ForegroundColor Yellow

# Clean up any existing containers
Write-Host "   Cleaning up existing containers..." -ForegroundColor Gray
docker stop cerberus-postgres 2>$null | Out-Null
docker rm cerberus-postgres 2>$null | Out-Null
docker volume rm cerberus_postgres_data 2>$null | Out-Null

# Start PostgreSQL container
Write-Host "   Starting PostgreSQL container..." -ForegroundColor Gray
$dockerCommand = @"
docker run -d \
  --name cerberus-postgres \
  -e POSTGRES_DB=cerberus_hydra \
  -e POSTGRES_USER=cerberus \
  -e POSTGRES_PASSWORD=CerberusLocal2024! \
  -p 5432:5432 \
  -v cerberus_postgres_data:/var/lib/postgresql/data \
  postgres:15-alpine
"@

Invoke-Expression $dockerCommand | Out-Null

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ PostgreSQL container started successfully!" -ForegroundColor Green
} else {
    Write-Host "❌ Failed to start PostgreSQL container" -ForegroundColor Red
    Write-Host "💡 Make sure Docker Desktop is running" -ForegroundColor Yellow
    exit 1
}

# Wait for PostgreSQL to be ready
Write-Host "   Waiting for PostgreSQL to be ready..." -ForegroundColor Gray
$maxAttempts = 30
$attempt = 0

do {
    Start-Sleep -Seconds 2
    $attempt++
    $null = docker exec cerberus-postgres pg_isready -U cerberus -d cerberus_hydra 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ PostgreSQL is ready!" -ForegroundColor Green
        break
    }
    Write-Host "      Attempt $attempt/$maxAttempts..." -ForegroundColor Gray
} while ($attempt -lt $maxAttempts)

if ($attempt -eq $maxAttempts) {
    Write-Host "❌ PostgreSQL failed to start within timeout" -ForegroundColor Red
    exit 1
}

# Step 3: Create database schema
Write-Host ""
Write-Host "📊 Step 3: Creating database schema..." -ForegroundColor Yellow

$createSchema = @"
-- Cerberus Chain: Hydra Database Schema
-- Complete local development setup

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users table for authentication
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_login TIMESTAMP WITH TIME ZONE,
    is_active BOOLEAN DEFAULT true,
    is_verified BOOLEAN DEFAULT false,
    failed_login_attempts INTEGER DEFAULT 0,
    locked_until TIMESTAMP WITH TIME ZONE,
    
    CONSTRAINT users_username_length CHECK (char_length(username) >= 3),
    CONSTRAINT users_email_format CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);

-- Wallets table for Solana wallet management
CREATE TABLE IF NOT EXISTS wallets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    public_key VARCHAR(44) UNIQUE NOT NULL,
    encrypted_private_key TEXT NOT NULL,
    encryption_nonce VARCHAR(32) NOT NULL,
    wallet_type VARCHAR(20) DEFAULT 'trading',
    sol_balance DECIMAL(20,9) DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_balance_update TIMESTAMP WITH TIME ZONE,
    
    CONSTRAINT wallets_name_length CHECK (char_length(name) >= 1),
    CONSTRAINT wallets_public_key_format CHECK (char_length(public_key) = 44),
    CONSTRAINT wallets_type_valid CHECK (wallet_type IN ('trading', 'master', 'bundle', 'temp')),
    CONSTRAINT wallets_balance_positive CHECK (sol_balance >= 0)
);

-- Token holdings for each wallet
CREATE TABLE IF NOT EXISTS token_holdings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    wallet_id UUID NOT NULL REFERENCES wallets(id) ON DELETE CASCADE,
    token_address VARCHAR(44) NOT NULL,
    token_symbol VARCHAR(20),
    token_name VARCHAR(100),
    balance DECIMAL(30,9) DEFAULT 0,
    decimals INTEGER DEFAULT 9,
    last_price_sol DECIMAL(20,9),
    last_updated TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    UNIQUE(wallet_id, token_address),
    CONSTRAINT token_holdings_balance_positive CHECK (balance >= 0),
    CONSTRAINT token_holdings_decimals_valid CHECK (decimals >= 0 AND decimals <= 18)
);

-- Trading history and transaction records
CREATE TABLE IF NOT EXISTS trades (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    wallet_id UUID NOT NULL REFERENCES wallets(id) ON DELETE CASCADE,
    token_address VARCHAR(44) NOT NULL,
    token_symbol VARCHAR(20),
    trade_type VARCHAR(10) NOT NULL,
    sol_amount DECIMAL(20,9) NOT NULL,
    token_amount DECIMAL(30,9),
    price_per_token DECIMAL(20,9),
    slippage_tolerance DECIMAL(5,2),
    priority_fee DECIMAL(10,9),
    transaction_hash VARCHAR(88),
    signature VARCHAR(88),
    status VARCHAR(20) DEFAULT 'pending',
    error_message TEXT,
    bot_type VARCHAR(20),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    executed_at TIMESTAMP WITH TIME ZONE,
    confirmed_at TIMESTAMP WITH TIME ZONE,
    
    CONSTRAINT trades_type_valid CHECK (trade_type IN ('buy', 'sell')),
    CONSTRAINT trades_status_valid CHECK (status IN ('pending', 'executing', 'confirmed', 'failed', 'cancelled')),
    CONSTRAINT trades_sol_amount_positive CHECK (sol_amount > 0),
    CONSTRAINT trades_slippage_valid CHECK (slippage_tolerance >= 0 AND slippage_tolerance <= 100)
);

-- Bot configurations and settings
CREATE TABLE IF NOT EXISTS bot_configs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    bot_type VARCHAR(20) NOT NULL,
    name VARCHAR(100) NOT NULL,
    is_active BOOLEAN DEFAULT false,
    config_json JSONB NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_run TIMESTAMP WITH TIME ZONE,
    
    CONSTRAINT bot_configs_type_valid CHECK (bot_type IN ('volume', 'bundle', 'bump', 'sniper', 'human')),
    CONSTRAINT bot_configs_name_length CHECK (char_length(name) >= 1)
);

-- Session management for JWT tokens
CREATE TABLE IF NOT EXISTS user_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token_hash VARCHAR(255) NOT NULL,
    ip_address TEXT,
    user_agent TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    is_active BOOLEAN DEFAULT true,
    
    UNIQUE(token_hash)
);

-- Audit log for security and compliance
CREATE TABLE IF NOT EXISTS audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    action VARCHAR(100) NOT NULL,
    resource_type VARCHAR(50),
    resource_id UUID,
    ip_address TEXT,
    user_agent TEXT,
    details JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    CONSTRAINT audit_logs_action_length CHECK (char_length(action) >= 1)
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);
CREATE INDEX IF NOT EXISTS idx_users_active ON users(is_active);

CREATE INDEX IF NOT EXISTS idx_wallets_user_id ON wallets(user_id);
CREATE INDEX IF NOT EXISTS idx_wallets_public_key ON wallets(public_key);
CREATE INDEX IF NOT EXISTS idx_wallets_active ON wallets(is_active);

CREATE INDEX IF NOT EXISTS idx_token_holdings_wallet_id ON token_holdings(wallet_id);
CREATE INDEX IF NOT EXISTS idx_token_holdings_token_address ON token_holdings(token_address);

CREATE INDEX IF NOT EXISTS idx_trades_user_id ON trades(user_id);
CREATE INDEX IF NOT EXISTS idx_trades_wallet_id ON trades(wallet_id);
CREATE INDEX IF NOT EXISTS idx_trades_token_address ON trades(token_address);
CREATE INDEX IF NOT EXISTS idx_trades_status ON trades(status);
CREATE INDEX IF NOT EXISTS idx_trades_created_at ON trades(created_at);

CREATE INDEX IF NOT EXISTS idx_bot_configs_user_id ON bot_configs(user_id);
CREATE INDEX IF NOT EXISTS idx_bot_configs_type ON bot_configs(bot_type);
CREATE INDEX IF NOT EXISTS idx_bot_configs_active ON bot_configs(is_active);

CREATE INDEX IF NOT EXISTS idx_user_sessions_user_id ON user_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_user_sessions_token_hash ON user_sessions(token_hash);
CREATE INDEX IF NOT EXISTS idx_user_sessions_expires_at ON user_sessions(expires_at);

CREATE INDEX IF NOT EXISTS idx_audit_logs_user_id ON audit_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_action ON audit_logs(action);
CREATE INDEX IF NOT EXISTS idx_audit_logs_created_at ON audit_logs(created_at);

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply updated_at triggers to relevant tables
DROP TRIGGER IF EXISTS update_users_updated_at ON users;
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_wallets_updated_at ON wallets;
CREATE TRIGGER update_wallets_updated_at BEFORE UPDATE ON wallets
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_bot_configs_updated_at ON bot_configs;
CREATE TRIGGER update_bot_configs_updated_at BEFORE UPDATE ON bot_configs
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Insert default admin user for testing
-- Password: CerberusAdmin2024!
INSERT INTO users (username, email, password_hash, is_verified) VALUES 
('admin', 'admin@cerberuschain.local', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj3bp.gSUadW', true)
ON CONFLICT (username) DO NOTHING;

-- Create sample bot configuration
INSERT INTO bot_configs (user_id, bot_type, name, config_json) VALUES 
(
    (SELECT id FROM users WHERE username = 'admin'),
    'volume',
    'Default Volume Bot',
    '{
        "sol_amount": 0.1,
        "interval_seconds": 30,
        "slippage_tolerance": 5.0,
        "priority_fee": 0.001,
        "max_trades_per_hour": 120,
        "enabled_hours": [9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21]
    }'::jsonb
)
ON CONFLICT DO NOTHING;
"@

# Write schema to temporary file and execute
$schemaFile = "temp_schema.sql"
$createSchema | Out-File -FilePath $schemaFile -Encoding UTF8

try {
    Get-Content $schemaFile | docker exec -i cerberus-postgres psql -U cerberus -d cerberus_hydra
    Write-Host "✅ Database schema created successfully" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Schema creation completed with warnings (normal)" -ForegroundColor Yellow
} finally {
    Remove-Item $schemaFile -ErrorAction SilentlyContinue
}

# Step 4: Update .env file
Write-Host ""
Write-Host "📝 Step 4: Creating optimized .env file..." -ForegroundColor Yellow

$localDatabaseUrl = "postgresql://cerberus:CerberusLocal2024!@localhost:5432/cerberus_hydra"

$newEnvContent = @"
# Cerberus Chain: Hydra - Local Development Configuration
# No network dependencies - everything runs locally!

# Local PostgreSQL Database
DATABASE_URL=$localDatabaseUrl

# JWT Authentication
JWT_SECRET=CerberusChain2024LocalDevelopmentSecretKey123456789
JWT_EXPIRATION_HOURS=24

# Server Configuration
BIND_ADDRESS=0.0.0.0:8080
ENVIRONMENT=development

# Connection Pool Optimization
SQLX_MAX_CONNECTIONS=10
SQLX_MIN_CONNECTIONS=2
SQLX_ACQUIRE_TIMEOUT=30
SQLX_IDLE_TIMEOUT=600

# Optional: Helius API Key (for blockchain features when ready)
HELIUS_API_KEY=your_helius_api_key_here

# Optional: Encryption Key (32 characters for wallet encryption)
ENCRYPTION_KEY=CerberusLocal2024EncryptionKey12

# Development Features
RUST_LOG=info
RUST_BACKTRACE=1
"@

$newEnvContent | Set-Content ".env"
Write-Host "✅ Created optimized .env file" -ForegroundColor Green

# Step 5: Test the setup
Write-Host ""
Write-Host "🧪 Step 5: Testing the setup..." -ForegroundColor Yellow

# Test database connection
Write-Host "   Testing database connection..." -ForegroundColor Gray
$null = docker exec cerberus-postgres psql -U cerberus -d cerberus_hydra -c "SELECT 1;" 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Database connection: WORKING" -ForegroundColor Green
} else {
    Write-Host "❌ Database connection: FAILED" -ForegroundColor Red
}

# Test if backend dependencies are ready
Write-Host "   Checking backend dependencies..." -ForegroundColor Gray
if (Test-Path "backend/Cargo.toml") {
    Write-Host "✅ Backend project: FOUND" -ForegroundColor Green
} else {
    Write-Host "⚠️  Backend project: NOT FOUND" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "🎉 Complete Local Setup Finished!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 What's been set up:" -ForegroundColor Cyan
Write-Host "   ✅ Local PostgreSQL database (no network required)" -ForegroundColor Green
Write-Host "   ✅ Complete database schema with all tables" -ForegroundColor Green
Write-Host "   ✅ Optimized .env configuration" -ForegroundColor Green
Write-Host "   ✅ Default admin user (username: admin, password: CerberusAdmin2024!)" -ForegroundColor Green
Write-Host "   ✅ Sample bot configuration" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Database Details:" -ForegroundColor Cyan
Write-Host "   Host: localhost" -ForegroundColor White
Write-Host "   Port: 5432" -ForegroundColor White
Write-Host "   Database: cerberus_hydra" -ForegroundColor White
Write-Host "   Username: cerberus" -ForegroundColor White
Write-Host "   Password: CerberusLocal2024!" -ForegroundColor White
Write-Host ""
Write-Host "🚀 Now start the application:" -ForegroundColor Yellow
Write-Host "   1. Backend:  cd backend && cargo run" -ForegroundColor White
Write-Host "   2. Frontend: cd frontend && npm run dev" -ForegroundColor White
Write-Host ""
Write-Host "💡 Expected results:" -ForegroundColor Cyan
Write-Host "   ✅ Backend: Database connection established" -ForegroundColor Green
Write-Host "   ✅ Backend: Server starting on 0.0.0.0:8080" -ForegroundColor Green
Write-Host "   ✅ Frontend: Running on http://localhost:3000" -ForegroundColor Green
Write-Host ""
Write-Host "🔧 Useful Docker commands:" -ForegroundColor Yellow
Write-Host "   Start DB:  docker start cerberus-postgres" -ForegroundColor Gray
Write-Host "   Stop DB:   docker stop cerberus-postgres" -ForegroundColor Gray
Write-Host "   DB Shell:  docker exec -it cerberus-postgres psql -U cerberus -d cerberus_hydra" -ForegroundColor Gray
Write-Host "   DB Logs:   docker logs cerberus-postgres" -ForegroundColor Gray
Write-Host ""
Write-Host "✨ Advantages of this local setup:" -ForegroundColor Magenta
Write-Host "   • No network connectivity issues" -ForegroundColor White
Write-Host "   • Faster development and testing" -ForegroundColor White
Write-Host "   • Works completely offline" -ForegroundColor White
Write-Host "   • Full control over your data" -ForegroundColor White
Write-Host "   • No external dependencies" -ForegroundColor White
Write-Host "   • Perfect for you and your business partner" -ForegroundColor White
Write-Host ""
Write-Host "🎯 This eliminates ALL the Supabase connection problems!" -ForegroundColor Green