//! Database module for Cerberus Chain: Hydra
//! Handles all database operations, connections, and migrations

pub mod connection;
pub mod models;
pub mod migrations;

pub use connection::*;
pub use models::*;

use sqlx::{PgPool, Row};
use anyhow::Result;

/// Initialize the database connection pool
pub async fn init_db_pool(database_url: &str) -> Result<PgPool> {
    let pool = PgPool::connect(database_url).await?;
    
    // Run migrations
    sqlx::migrate!("./database/migrations").run(&pool).await?;
    
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
    let row = sqlx::query(r#"
        SELECT 
            (SELECT COUNT(*) FROM users) as user_count,
            (SELECT COUNT(*) FROM wallets) as wallet_count,
            (SELECT COUNT(*) FROM trades) as trade_count,
            (SELECT COUNT(*) FROM bot_configs WHERE is_active = true) as active_bot_count
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