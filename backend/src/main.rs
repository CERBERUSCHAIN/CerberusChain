//! Cerberus Chain: Hydra Backend
//! Advanced Solana Memecoin Trading Bot
//! 
//! The three-headed guardian protecting your memecoin investments
//! with military precision, transparency, and trust.

use actix_web::{web, App, HttpServer, middleware::Logger, middleware::Cors};
use actix_cors::Cors as ActixCors;
use dotenv::dotenv;
use std::env;
use anyhow::Result;

mod auth;
mod api;
mod database;
mod utils;
mod config;

use auth::AuthService;
use database::{init_db_pool, health_check, get_db_stats};

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    dotenv().ok();
    env_logger::init();
    
    log::info!("🐺 Starting Cerberus Chain: Hydra Backend...");
    
    // Initialize database connection
    let database_url = env::var("DATABASE_URL")
        .unwrap_or_else(|_| "postgresql://postgres:password@db.bervahrnaauhznctodie.supabase.co:5432/postgres".to_string());
    
    let db_pool = match init_db_pool(&database_url).await {
        Ok(pool) => {
            log::info!("✅ Database connection established");
            pool
        }
        Err(e) => {
            log::error!("❌ Failed to connect to database: {}", e);
            log::info!("💡 Make sure DATABASE_URL is correct in your .env file");
            std::process::exit(1);
        }
    };

    // Test database connection
    if let Err(e) = health_check(&db_pool).await {
        log::error!("❌ Database health check failed: {}", e);
        std::process::exit(1);
    }

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
    
    HttpServer::new(move || {
        let cors = ActixCors::default()
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