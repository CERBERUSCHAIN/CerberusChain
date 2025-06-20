//! Database connection management for Cerberus Chain: Hydra

use sqlx::{PgPool, postgres::PgPoolOptions};
use std::time::Duration;
use anyhow::Result;

/// Database connection configuration
#[derive(Debug, Clone)]
pub struct DatabaseConfig {
    pub url: String,
    pub max_connections: u32,
    pub min_connections: u32,
    pub connect_timeout: Duration,
    pub idle_timeout: Duration,
}

impl Default for DatabaseConfig {
    fn default() -> Self {
        Self {
            url: std::env::var("DATABASE_URL")
                .unwrap_or_else(|_| "postgresql://cerberus:password@localhost:5432/cerberus_hydra".to_string()),
            max_connections: 20,
            min_connections: 5,
            connect_timeout: Duration::from_secs(30),
            idle_timeout: Duration::from_secs(600),
        }
    }
}

/// Create a new database connection pool
pub async fn create_pool(config: DatabaseConfig) -> Result<PgPool> {
    let pool = PgPoolOptions::new()
        .max_connections(config.max_connections)
        .min_connections(config.min_connections)
        .acquire_timeout(config.connect_timeout)
        .idle_timeout(config.idle_timeout)
        .connect(&config.url)
        .await?;

    log::info!("Database connection pool created with {} max connections", config.max_connections);
    Ok(pool)
}

/// Test database connection
pub async fn test_connection(pool: &PgPool) -> Result<()> {
    sqlx::query("SELECT 1")
        .fetch_one(pool)
        .await?;
    
    log::info!("Database connection test successful");
    Ok(())
}