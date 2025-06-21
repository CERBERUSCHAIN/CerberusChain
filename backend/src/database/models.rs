//! Database models for Cerberus Chain: Hydra

use serde::{Deserialize, Serialize};
use sqlx::FromRow;
use uuid::Uuid;
use chrono::{DateTime, Utc};
use rust_decimal::Decimal;

/// User model for authentication and user management
#[derive(Debug, Clone, Serialize, Deserialize, FromRow)]
pub struct User {
    pub id: Uuid,
    pub username: String,
    pub email: String,
    pub password_hash: String,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
    pub last_login: Option<DateTime<Utc>>,
    pub is_active: bool,
    pub is_verified: bool,
    pub failed_login_attempts: i32,
    pub locked_until: Option<DateTime<Utc>>,
}

/// User creation request
#[derive(Debug, Deserialize)]
pub struct CreateUserRequest {
    pub username: String,
    pub email: String,
    pub password: String,
}

/// User login request
#[derive(Debug, Deserialize)]
pub struct LoginRequest {
    pub username: String,
    pub password: String,
}

/// User response (without sensitive data)
#[derive(Debug, Serialize)]
pub struct UserResponse {
    pub id: Uuid,
    pub username: String,
    pub email: String,
    pub created_at: DateTime<Utc>,
    pub last_login: Option<DateTime<Utc>>,
    pub is_verified: bool,
}

impl From<User> for UserResponse {
    fn from(user: User) -> Self {
        Self {
            id: user.id,
            username: user.username,
            email: user.email,
            created_at: user.created_at,
            last_login: user.last_login,
            is_verified: user.is_verified,
        }
    }
}

/// Wallet model for Solana wallet management
#[derive(Debug, Clone, Serialize, Deserialize, FromRow)]
pub struct Wallet {
    pub id: Uuid,
    pub user_id: Uuid,
    pub name: String,
    pub public_key: String,
    pub encrypted_private_key: String,
    pub encryption_nonce: String,
    pub wallet_type: String,
    pub sol_balance: Decimal,
    pub is_active: bool,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
    pub last_balance_update: Option<DateTime<Utc>>,
}

/// Wallet creation request
#[derive(Debug, Deserialize)]
pub struct CreateWalletRequest {
    pub name: String,
    pub wallet_type: Option<String>,
}

/// Wallet response (without private key)
#[derive(Debug, Serialize)]
pub struct WalletResponse {
    pub id: Uuid,
    pub name: String,
    pub public_key: String,
    pub wallet_type: String,
    pub sol_balance: Decimal,
    pub is_active: bool,
    pub created_at: DateTime<Utc>,
    pub last_balance_update: Option<DateTime<Utc>>,
}

impl From<Wallet> for WalletResponse {
    fn from(wallet: Wallet) -> Self {
        Self {
            id: wallet.id,
            name: wallet.name,
            public_key: wallet.public_key,
            wallet_type: wallet.wallet_type,
            sol_balance: wallet.sol_balance,
            is_active: wallet.is_active,
            created_at: wallet.created_at,
            last_balance_update: wallet.last_balance_update,
        }
    }
}

/// Token holding model
#[derive(Debug, Clone, Serialize, Deserialize, FromRow)]
pub struct TokenHolding {
    pub id: Uuid,
    pub wallet_id: Uuid,
    pub token_address: String,
    pub token_symbol: Option<String>,
    pub token_name: Option<String>,
    pub balance: Decimal,
    pub decimals: i32,
    pub last_price_sol: Option<Decimal>,
    pub last_updated: DateTime<Utc>,
}

/// Trade model for transaction history
#[derive(Debug, Clone, Serialize, Deserialize, FromRow)]
pub struct Trade {
    pub id: Uuid,
    pub user_id: Uuid,
    pub wallet_id: Uuid,
    pub token_address: String,
    pub token_symbol: Option<String>,
    pub trade_type: String,
    pub sol_amount: Decimal,
    pub token_amount: Option<Decimal>,
    pub price_per_token: Option<Decimal>,
    pub slippage_tolerance: Option<Decimal>,
    pub priority_fee: Option<Decimal>,
    pub transaction_hash: Option<String>,
    pub signature: Option<String>,
    pub status: String,
    pub error_message: Option<String>,
    pub bot_type: Option<String>,
    pub created_at: DateTime<Utc>,
    pub executed_at: Option<DateTime<Utc>>,
    pub confirmed_at: Option<DateTime<Utc>>,
}

/// Trade creation request
#[derive(Debug, Deserialize)]
pub struct CreateTradeRequest {
    pub wallet_id: Uuid,
    pub token_address: String,
    pub trade_type: String,
    pub sol_amount: Decimal,
    pub slippage_tolerance: Option<Decimal>,
    pub priority_fee: Option<Decimal>,
}

/// Bot configuration model
#[derive(Debug, Clone, Serialize, Deserialize, FromRow)]
pub struct BotConfig {
    pub id: Uuid,
    pub user_id: Uuid,
    pub bot_type: String,
    pub name: String,
    pub is_active: bool,
    pub config_json: serde_json::Value,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
    pub last_run: Option<DateTime<Utc>>,
}

/// Bot configuration request
#[derive(Debug, Deserialize)]
pub struct CreateBotConfigRequest {
    pub bot_type: String,
    pub name: String,
    pub config: serde_json::Value,
}

/// JWT claims structure
#[derive(Debug, Serialize, Deserialize)]
pub struct Claims {
    pub sub: String,  // User ID
    pub username: String,
    pub exp: usize,   // Expiration time
    pub iat: usize,   // Issued at
    pub session_id: String,
}

/// API response wrapper
#[derive(Debug, Serialize)]
pub struct ApiResponse<T> {
    pub success: bool,
    pub data: Option<T>,
    pub message: Option<String>,
    pub error: Option<String>,
}

impl<T> ApiResponse<T> {
    pub fn success(data: T) -> Self {
        Self {
            success: true,
            data: Some(data),
            message: None,
            error: None,
        }
    }

    pub fn error(error: String) -> Self {
        Self {
            success: false,
            data: None,
            message: None,
            error: Some(error),
        }
    }

    pub fn message(message: String) -> Self {
        Self {
            success: true,
            data: None,
            message: Some(message),
            error: None,
        }
    }
}

/// Pagination parameters
#[derive(Debug, Deserialize)]
pub struct PaginationParams {
    pub page: Option<u32>,
    pub limit: Option<u32>,
}

impl Default for PaginationParams {
    fn default() -> Self {
        Self {
            page: Some(1),
            limit: Some(20),
        }
    }
}

/// Paginated response
#[derive(Debug, Serialize)]
pub struct PaginatedResponse<T> {
    pub data: Vec<T>,
    pub page: u32,
    pub limit: u32,
    pub total: u64,
    pub total_pages: u32,
}