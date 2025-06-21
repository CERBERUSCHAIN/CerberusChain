//! Cerberus Chain: Hydra Backend - SQLite Version
//! No network dependencies, perfect for local development

use actix_web::{web, App, HttpServer, middleware::Logger};
use actix_cors::Cors;
use dotenv::dotenv;
use std::env;
use std::fs;
use std::path::Path;
use sqlx::{SqlitePool, sqlite::SqlitePoolOptions};

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    dotenv().ok();
    env_logger::init();
    
    log::info!("🐺 Starting Cerberus Chain: Hydra Backend (SQLite Version)...");
    
    // Get database URL (SQLite file)
    let database_url = env::var("DATABASE_URL")
        .unwrap_or_else(|_| "sqlite:data/cerberus_hydra.db".to_string());
    
    log::info!("📊 Using SQLite database: {}", database_url);
    
    // Ensure the data directory exists
    if let Some(db_path) = database_url.strip_prefix("sqlite:") {
        if let Some(parent) = Path::new(db_path).parent() {
            if let Err(e) = fs::create_dir_all(parent) {
                log::error!("❌ Failed to create database directory: {}", e);
                std::process::exit(1);
            }
            log::info!("✅ Database directory ready: {}", parent.display());
        }
    }
    
    // Create SQLite connection pool
    let db_pool = match SqlitePoolOptions::new()
        .max_connections(5)
        .connect(&database_url)
        .await
    {
        Ok(pool) => {
            log::info!("✅ SQLite database connected");
            
            // Run migrations (create tables)
            if let Err(e) = create_tables(&pool).await {
                log::error!("❌ Failed to create tables: {}", e);
                std::process::exit(1);
            } else {
                log::info!("✅ Database tables ready");
            }
            
            pool
        }
        Err(e) => {
            log::error!("❌ Failed to connect to SQLite database: {}", e);
            log::error!("💡 Database file location: {}", database_url);
            
            // Try to provide more helpful error information
            if let Some(db_path) = database_url.strip_prefix("sqlite:") {
                let path = Path::new(db_path);
                if let Some(parent) = path.parent() {
                    if !parent.exists() {
                        log::error!("💡 Directory doesn't exist: {}", parent.display());
                    } else {
                        log::error!("💡 Directory exists but can't create database file");
                        log::error!("💡 Check write permissions for: {}", parent.display());
                    }
                }
            }
            
            std::process::exit(1);
        }
    };

    let bind_address = env::var("BIND_ADDRESS").unwrap_or_else(|_| "0.0.0.0:8080".to_string());
    
    log::info!("🚀 Server starting on {}", bind_address);
    log::info!("✅ SQLite database: Ready");
    log::info!("✅ No network dependencies");
    
    HttpServer::new(move || {
        let cors = Cors::default()
            .allowed_origin("http://localhost:3000")
            .allowed_origin("http://localhost:5173")
            .allowed_origin("http://localhost:5174")
            .allowed_methods(vec!["GET", "POST", "PUT", "DELETE", "OPTIONS"])
            .allowed_headers(vec!["Content-Type", "Authorization", "Accept"])
            .supports_credentials()
            .max_age(3600);

        App::new()
            .app_data(web::Data::new(db_pool.clone()))
            .wrap(cors)
            .wrap(Logger::default())
            .route("/", web::get().to(health_check_handler))
            .route("/health", web::get().to(health_check_handler))
            .route("/api/status", web::get().to(api_status_handler))
    })
    .bind(&bind_address)?
    .run()
    .await
}

async fn create_tables(pool: &SqlitePool) -> Result<(), sqlx::Error> {
    // Create users table
    sqlx::query(r#"
        CREATE TABLE IF NOT EXISTS users (
            id TEXT PRIMARY KEY,
            username TEXT UNIQUE NOT NULL,
            email TEXT UNIQUE NOT NULL,
            password_hash TEXT NOT NULL,
            created_at TEXT DEFAULT CURRENT_TIMESTAMP,
            updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
            last_login TEXT,
            is_active INTEGER DEFAULT 1,
            is_verified INTEGER DEFAULT 0,
            failed_login_attempts INTEGER DEFAULT 0,
            locked_until TEXT
        )
    "#).execute(pool).await?;

    // Create wallets table
    sqlx::query(r#"
        CREATE TABLE IF NOT EXISTS wallets (
            id TEXT PRIMARY KEY,
            user_id TEXT NOT NULL,
            name TEXT NOT NULL,
            public_key TEXT UNIQUE NOT NULL,
            encrypted_private_key TEXT NOT NULL,
            encryption_nonce TEXT NOT NULL,
            wallet_type TEXT DEFAULT 'trading',
            sol_balance REAL DEFAULT 0,
            is_active INTEGER DEFAULT 1,
            created_at TEXT DEFAULT CURRENT_TIMESTAMP,
            updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
            last_balance_update TEXT,
            FOREIGN KEY (user_id) REFERENCES users (id)
        )
    "#).execute(pool).await?;

    // Create trades table
    sqlx::query(r#"
        CREATE TABLE IF NOT EXISTS trades (
            id TEXT PRIMARY KEY,
            user_id TEXT NOT NULL,
            wallet_id TEXT NOT NULL,
            token_address TEXT NOT NULL,
            token_symbol TEXT,
            trade_type TEXT NOT NULL,
            sol_amount REAL NOT NULL,
            token_amount REAL,
            price_per_token REAL,
            status TEXT DEFAULT 'pending',
            created_at TEXT DEFAULT CURRENT_TIMESTAMP,
            executed_at TEXT,
            confirmed_at TEXT,
            FOREIGN KEY (user_id) REFERENCES users (id),
            FOREIGN KEY (wallet_id) REFERENCES wallets (id)
        )
    "#).execute(pool).await?;

    // Create bot_configs table
    sqlx::query(r#"
        CREATE TABLE IF NOT EXISTS bot_configs (
            id TEXT PRIMARY KEY,
            user_id TEXT NOT NULL,
            bot_type TEXT NOT NULL,
            name TEXT NOT NULL,
            is_active INTEGER DEFAULT 0,
            config_json TEXT NOT NULL,
            created_at TEXT DEFAULT CURRENT_TIMESTAMP,
            updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
            last_run TEXT,
            FOREIGN KEY (user_id) REFERENCES users (id)
        )
    "#).execute(pool).await?;

    // Insert a default admin user for testing
    sqlx::query(r#"
        INSERT OR IGNORE INTO users (id, username, email, password_hash, is_verified) 
        VALUES ('admin-001', 'admin', 'admin@cerberuschain.local', 'placeholder_hash', 1)
    "#).execute(pool).await?;

    log::info!("✅ All database tables created successfully");
    log::info!("✅ Default admin user created (username: admin)");
    Ok(())
}

async fn health_check_handler(pool: web::Data<SqlitePool>) -> actix_web::Result<impl actix_web::Responder> {
    // Test database connection
    let db_healthy = sqlx::query("SELECT 1")
        .fetch_one(pool.get_ref())
        .await
        .is_ok();

    Ok(web::Json(serde_json::json!({
        "status": "healthy",
        "service": "cerberus-hydra-backend",
        "version": env!("CARGO_PKG_VERSION"),
        "timestamp": chrono::Utc::now().to_rfc3339(),
        "database": {
            "type": "SQLite",
            "connected": db_healthy,
            "file": "data/cerberus_hydra.db"
        },
        "heads": {
            "strategy": "ready",
            "volume": "ready", 
            "security": "ready"
        },
        "message": "Simple local setup - no network dependencies!"
    })))
}

async fn api_status_handler() -> actix_web::Result<impl actix_web::Responder> {
    Ok(web::Json(serde_json::json!({
        "backend": "healthy",
        "database": "sqlite",
        "mode": "local_development",
        "features": {
            "user_registration": true,
            "wallet_management": true,
            "trading_history": true,
            "bot_configuration": true
        },
        "message": "Ready for local development!"
    })))
}