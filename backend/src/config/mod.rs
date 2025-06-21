//! Configuration management

use std::env;

#[derive(Debug, Clone)]
pub struct Config {
    pub database_url: String,
    pub jwt_secret: String,
    pub jwt_expiration_hours: u64,
    pub bind_address: String,
    pub helius_api_key: Option<String>,
    pub environment: String,
}

impl Config {
    pub fn from_env() -> Self {
        Self {
            database_url: env::var("DATABASE_URL")
                .unwrap_or_else(|_| "postgresql://postgres:password@db.bervahrnaauhznctodie.supabase.co:5432/postgres".to_string()),
            jwt_secret: env::var("JWT_SECRET")
                .unwrap_or_else(|_| "cerberus_default_secret_change_in_production".to_string()),
            jwt_expiration_hours: env::var("JWT_EXPIRATION_HOURS")
                .unwrap_or_else(|_| "24".to_string())
                .parse()
                .unwrap_or(24),
            bind_address: env::var("BIND_ADDRESS")
                .unwrap_or_else(|_| "0.0.0.0:8080".to_string()),
            helius_api_key: env::var("HELIUS_API_KEY").ok(),
            environment: env::var("ENVIRONMENT")
                .unwrap_or_else(|_| "development".to_string()),
        }
    }
    
    pub fn is_production(&self) -> bool {
        self.environment == "production"
    }
    
    pub fn is_development(&self) -> bool {
        self.environment == "development"
    }
}