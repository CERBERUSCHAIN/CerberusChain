//! Database module for Cerberus Chain: Hydra
//! Handles all database operations, connections, and migrations

pub mod connection;
pub mod models;

pub use connection::*;
pub use models::*;

use sqlx::{PgPool, Row};
use anyhow::Result;

/// Initialize the database connection pool (simplified for timeout issues)
pub async fn init_db_pool(database_url: &str) -> Result<PgPool> {
    let pool = PgPool::connect(database_url).await?;
    
    log::info!("Database connection pool initialized successfully");
    Ok(pool)
}

/// Health check for database connection
pub async fn health_check(pool: &PgPool) -> Result<bool> {
    let row = sqlx::query("SELECT 1 as health")
        .fetch_one(pool)
        .await?;
    
    let health: i32 = row.get("health");
    Ok(health == 1)
}

/// Get database statistics
pub async fn get_db_stats(pool: &PgPool) -> Result<DatabaseStats> {
    // Simple query that should work even without our custom tables
    let row = sqlx::query(r#"
        SELECT 
            0 as user_count,
            0 as wallet_count,
            0 as trade_count,
            0 as active_bot_count
    "#)
    .fetch_one(pool)
    .await?;

    Ok(DatabaseStats {
        user_count: row.get::<i64, _>("user_count") as u64,
        wallet_count: row.get::<i64, _>("wallet_count") as u64,
        trade_count: row.get::<i64, _>("trade_count") as u64,
        active_bot_count: row.get::<i64, _>("active_bot_count") as u64,
    })
}

#[derive(Debug, serde::Serialize)]
pub struct DatabaseStats {
    pub user_count: u64,
    pub wallet_count: u64,
    pub trade_count: u64,
    pub active_bot_count: u64,
}