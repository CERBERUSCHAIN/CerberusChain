//! Utility functions and helpers

use anyhow::Result;
use uuid::Uuid;

/// Generate a new UUID
pub fn generate_uuid() -> Uuid {
    Uuid::new_v4()
}

/// Validate email format
pub fn validate_email(email: &str) -> bool {
    email.contains('@') && email.contains('.') && email.len() > 5
}

/// Validate username format
pub fn validate_username(username: &str) -> Result<()> {
    if username.len() < 3 {
        return Err(anyhow::anyhow!("Username must be at least 3 characters long"));
    }
    
    if username.len() > 50 {
        return Err(anyhow::anyhow!("Username must be less than 50 characters"));
    }
    
    if !username.chars().all(|c| c.is_alphanumeric() || c == '_' || c == '-') {
        return Err(anyhow::anyhow!("Username can only contain letters, numbers, underscores, and hyphens"));
    }
    
    Ok(())
}

/// Format SOL amount for display
pub fn format_sol_amount(amount: rust_decimal::Decimal) -> String {
    format!("{:.4} SOL", amount)
}

/// Get current timestamp
pub fn current_timestamp() -> chrono::DateTime<chrono::Utc> {
    chrono::Utc::now()
}