-- Cerberus Chain: Hydra - Initial Database Schema
-- This creates the core tables for user management, wallet storage, and trading history

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users table for authentication and user management
CREATE TABLE users (
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
    
    -- Constraints
    CONSTRAINT users_username_length CHECK (char_length(username) >= 3),
    CONSTRAINT users_email_format CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);

-- Wallets table for Solana wallet management
CREATE TABLE wallets (
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
    
    -- Constraints
    CONSTRAINT wallets_name_length CHECK (char_length(name) >= 1),
    CONSTRAINT wallets_public_key_format CHECK (char_length(public_key) = 44),
    CONSTRAINT wallets_type_valid CHECK (wallet_type IN ('trading', 'master', 'bundle', 'temp')),
    CONSTRAINT wallets_balance_positive CHECK (sol_balance >= 0)
);

-- Token holdings for each wallet
CREATE TABLE token_holdings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    wallet_id UUID NOT NULL REFERENCES wallets(id) ON DELETE CASCADE,
    token_address VARCHAR(44) NOT NULL,
    token_symbol VARCHAR(20),
    token_name VARCHAR(100),
    balance DECIMAL(30,9) DEFAULT 0,
    decimals INTEGER DEFAULT 9,
    last_price_sol DECIMAL(20,9),
    last_updated TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Unique constraint to prevent duplicate token holdings per wallet
    UNIQUE(wallet_id, token_address),
    
    -- Constraints
    CONSTRAINT token_holdings_balance_positive CHECK (balance >= 0),
    CONSTRAINT token_holdings_decimals_valid CHECK (decimals >= 0 AND decimals <= 18)
);

-- Trading history and transaction records
CREATE TABLE trades (
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
    
    -- Constraints
    CONSTRAINT trades_type_valid CHECK (trade_type IN ('buy', 'sell')),
    CONSTRAINT trades_status_valid CHECK (status IN ('pending', 'executing', 'confirmed', 'failed', 'cancelled')),
    CONSTRAINT trades_sol_amount_positive CHECK (sol_amount > 0),
    CONSTRAINT trades_slippage_valid CHECK (slippage_tolerance >= 0 AND slippage_tolerance <= 100)
);

-- Bot configurations and settings
CREATE TABLE bot_configs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    bot_type VARCHAR(20) NOT NULL,
    name VARCHAR(100) NOT NULL,
    is_active BOOLEAN DEFAULT false,
    config_json JSONB NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_run TIMESTAMP WITH TIME ZONE,
    
    -- Constraints
    CONSTRAINT bot_configs_type_valid CHECK (bot_type IN ('volume', 'bundle', 'bump', 'sniper', 'human')),
    CONSTRAINT bot_configs_name_length CHECK (char_length(name) >= 1)
);

-- Session management for JWT tokens
CREATE TABLE user_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token_hash VARCHAR(255) NOT NULL,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    is_active BOOLEAN DEFAULT true,
    
    -- Index for efficient token lookups
    UNIQUE(token_hash)
);

-- Audit log for security and compliance
CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    action VARCHAR(100) NOT NULL,
    resource_type VARCHAR(50),
    resource_id UUID,
    ip_address INET,
    user_agent TEXT,
    details JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT audit_logs_action_length CHECK (char_length(action) >= 1)
);

-- Create indexes for better performance
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_active ON users(is_active);

CREATE INDEX idx_wallets_user_id ON wallets(user_id);
CREATE INDEX idx_wallets_public_key ON wallets(public_key);
CREATE INDEX idx_wallets_active ON wallets(is_active);

CREATE INDEX idx_token_holdings_wallet_id ON token_holdings(wallet_id);
CREATE INDEX idx_token_holdings_token_address ON token_holdings(token_address);

CREATE INDEX idx_trades_user_id ON trades(user_id);
CREATE INDEX idx_trades_wallet_id ON trades(wallet_id);
CREATE INDEX idx_trades_token_address ON trades(token_address);
CREATE INDEX idx_trades_status ON trades(status);
CREATE INDEX idx_trades_created_at ON trades(created_at);

CREATE INDEX idx_bot_configs_user_id ON bot_configs(user_id);
CREATE INDEX idx_bot_configs_type ON bot_configs(bot_type);
CREATE INDEX idx_bot_configs_active ON bot_configs(is_active);

CREATE INDEX idx_user_sessions_user_id ON user_sessions(user_id);
CREATE INDEX idx_user_sessions_token_hash ON user_sessions(token_hash);
CREATE INDEX idx_user_sessions_expires_at ON user_sessions(expires_at);

CREATE INDEX idx_audit_logs_user_id ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_action ON audit_logs(action);
CREATE INDEX idx_audit_logs_created_at ON audit_logs(created_at);

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply updated_at triggers to relevant tables
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_wallets_updated_at BEFORE UPDATE ON wallets
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_bot_configs_updated_at BEFORE UPDATE ON bot_configs
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Insert default admin user (password: CerberusAdmin2024!)
-- Note: This is a placeholder hash - will be properly generated when user registers
INSERT INTO users (username, email, password_hash, is_verified) VALUES 
('admin', 'admin@cerberuschain.com', 'placeholder_hash_will_be_replaced', true);