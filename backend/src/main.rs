//! Cerberus Chain: Hydra Backend
//! Advanced Solana Memecoin Trading Bot
//! 
//! The three-headed guardian protecting your memecoin investments
//! with military precision, transparency, and trust.

use actix_web::{web, App, HttpServer, middleware::Logger};
use actix_cors::Cors;
use dotenv::dotenv;
use std::env;
use sqlx::{PgPool, postgres::PgPoolOptions};
use std::time::Duration;

mod auth;
mod api;
mod database;
mod utils;
mod config;

use auth::AuthService;
use database::{health_check, get_db_stats};

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    dotenv().ok();
    env_logger::init();
    
    log::info!("🐺 Starting Cerberus Chain: Hydra Backend...");
    
    // Get database URL
    let database_url = env::var("DATABASE_URL")
        .unwrap_or_else(|_| {
            log::warn!("DATABASE_URL not found in environment, using default");
            "postgresql://postgres:password@localhost:5432/postgres".to_string()
        });
    
    log::info!("📊 Attempting database connection to: {}", 
        database_url.split('@').nth(1).unwrap_or("unknown"));
    
    // Create connection pool with better timeout settings
    let db_pool = match create_optimized_pool(&database_url).await {
        Ok(pool) => {
            log::info!("✅ Database connection established");
            
            // Test the connection
            match health_check(&pool).await {
                Ok(_) => {
                    log::info!("✅ Database health check passed");
                    pool
                }
                Err(e) => {
                    log::error!("❌ Database health check failed: {}", e);
                    log::info!("🔄 Starting server with limited functionality...");
                    return start_server_without_db().await;
                }
            }
        }
        Err(e) => {
            log::error!("❌ Failed to connect to database: {}", e);
            log::info!("💡 Possible solutions:");
            log::info!("   1. Check your .env file has the correct DATABASE_URL");
            log::info!("   2. Verify your internet connection");
            log::info!("   3. Check if Supabase project is accessible");
            log::info!("   4. Try using a local PostgreSQL database for development");
            log::info!("🔄 Starting server without database connection for testing...");
            
            return start_server_without_db().await;
        }
    };

    // Initialize authentication service
    let jwt_secret = env::var("JWT_SECRET")
        .unwrap_or_else(|_| "cerberus_default_secret_change_in_production".to_string());
    let token_expiration_hours = env::var("JWT_EXPIRATION_HOURS")
        .unwrap_or_else(|_| "24".to_string())
        .parse::<u64>()
        .unwrap_or(24);

    let auth_service = AuthService::new(jwt_secret.clone(), token_expiration_hours);

    let bind_address = env::var("BIND_ADDRESS").unwrap_or_else(|_| "0.0.0.0:8080".to_string());
    
    log::info!("🚀 Server starting on {}", bind_address);
    log::info!("🔐 JWT expiration: {} hours", token_expiration_hours);
    log::info!("✅ Database connection: Active");
    
    HttpServer::new(move || {
        let cors = Cors::default()
            .allowed_origin("http://localhost:3000")
            .allowed_origin("http://localhost:5173")
            .allowed_origin("http://127.0.0.1:3000")
            .allowed_origin("http://127.0.0.1:5173")
            .allowed_methods(vec!["GET", "POST", "PUT", "DELETE", "OPTIONS"])
            .allowed_headers(vec!["Content-Type", "Authorization", "Accept"])
            .supports_credentials()
            .max_age(3600);

        App::new()
            .app_data(web::Data::new(db_pool.clone()))
            .app_data(web::Data::new(auth_service.clone()))
            .wrap(cors)
            .wrap(Logger::default())
            .route("/", web::get().to(health_check_handler))
            .route("/health", web::get().to(health_check_handler))
            .route("/api/status", web::get().to(api_status_handler))
            .configure(api::configure_routes)
    })
    .bind(&bind_address)?
    .run()
    .await
}

// Create optimized connection pool with better timeout settings
async fn create_optimized_pool(database_url: &str) -> Result<PgPool, sqlx::Error> {
    PgPoolOptions::new()
        .max_connections(5)  // Reduced from default to avoid overwhelming Supabase
        .min_connections(1)  // Keep at least one connection
        .acquire_timeout(Duration::from_secs(30))  // 30 seconds to get a connection
        .idle_timeout(Duration::from_secs(300))    // 5 minutes idle timeout
        .max_lifetime(Duration::from_secs(1800))   // 30 minutes max lifetime
        .test_before_acquire(true)  // Test connections before use
        .connect(database_url)
        .await
}

// Fallback server without database for development/testing
async fn start_server_without_db() -> std::io::Result<()> {
    let bind_address = env::var("BIND_ADDRESS").unwrap_or_else(|_| "0.0.0.0:8080".to_string());
    
    log::info!("🚀 Server starting on {} (NO DATABASE)", bind_address);
    log::warn!("⚠️  Running in limited mode without database connection");
    
    HttpServer::new(|| {
        let cors = Cors::default()
            .allowed_origin("http://localhost:3000")
            .allowed_origin("http://localhost:5173")
            .allowed_origin("http://127.0.0.1:3000")
            .allowed_origin("http://127.0.0.1:5173")
            .allowed_methods(vec!["GET", "POST", "PUT", "DELETE", "OPTIONS"])
            .allowed_headers(vec!["Content-Type", "Authorization", "Accept"])
            .supports_credentials()
            .max_age(3600);

        App::new()
            .wrap(cors)
            .wrap(Logger::default())
            .route("/", web::get().to(simple_health_check))
            .route("/health", web::get().to(simple_health_check))
            .route("/api/status", web::get().to(simple_api_status))
    })
    .bind(&bind_address)?
    .run()
    .await
}

async fn health_check_handler(pool: web::Data<sqlx::PgPool>) -> actix_web::Result<impl actix_web::Responder> {
    let db_healthy = health_check(pool.get_ref()).await.unwrap_or(false);
    let db_stats = get_db_stats(pool.get_ref()).await.ok();

    Ok(web::Json(serde_json::json!({
        "status": "healthy",
        "service": "cerberus-hydra-backend",
        "version": env!("CARGO_PKG_VERSION"),
        "timestamp": chrono::Utc::now().to_rfc3339(),
        "database": {
            "connected": db_healthy,
            "stats": db_stats
        },
        "heads": {
            "strategy": "active",
            "volume": "monitoring", 
            "security": "protecting"
        }
    })))
}

async fn api_status_handler(pool: web::Data<sqlx::PgPool>) -> actix_web::Result<impl actix_web::Responder> {
    let db_healthy = health_check(pool.get_ref()).await.unwrap_or(false);
    let helius_configured = env::var("HELIUS_API_KEY").is_ok();

    Ok(web::Json(serde_json::json!({
        "backend": "healthy",
        "database": if db_healthy { "connected" } else { "disconnected" },
        "helius": if helius_configured { "configured" } else { "not_configured" },
        "authentication": "enabled",
        "bots": {
            "volume": "stopped",
            "bundle": "stopped", 
            "bump": "stopped",
            "sniper": "stopped"
        },
        "features": {
            "user_registration": true,
            "wallet_management": true,
            "trading_history": true,
            "bot_configuration": true
        }
    })))
}

// Simple handlers for no-database mode
async fn simple_health_check() -> actix_web::Result<impl actix_web::Responder> {
    Ok(web::Json(serde_json::json!({
        "status": "healthy",
        "service": "cerberus-hydra-backend",
        "version": env!("CARGO_PKG_VERSION"),
        "timestamp": chrono::Utc::now().to_rfc3339(),
        "database": {
            "connected": false,
            "message": "Running without database connection"
        },
        "mode": "development"
    })))
}

async fn simple_api_status() -> actix_web::Result<impl actix_web::Responder> {
    Ok(web::Json(serde_json::json!({
        "backend": "healthy",
        "database": "disconnected",
        "mode": "development",
        "message": "Backend running without database for testing"
    })))
}