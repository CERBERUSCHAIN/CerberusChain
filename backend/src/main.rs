//! Cerberus Chain: Hydra Backend
//! Advanced Solana Memecoin Trading Bot
//! 
//! The three-headed guardian protecting your memecoin investments
//! with military precision, transparency, and trust.

use actix_web::{web, App, HttpServer, middleware::Logger};
use actix_cors::Cors;
use dotenv::dotenv;
use std::env;

mod auth;
mod api;
mod bots;
mod wallet;
mod database;
mod helius;
mod notifications;
mod utils;
mod config;

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    dotenv().ok();
    env_logger::init();
    
    log::info!("Starting Cerberus Chain: Hydra Backend...");
    
    let bind_address = env::var("BIND_ADDRESS").unwrap_or_else(|_| "0.0.0.0:8080".to_string());
    
    log::info!("Server starting on {}", bind_address);
    
    HttpServer::new(|| {
        let cors = Cors::default()
            .allowed_origin("http://localhost:5173")
            .allowed_origin("http://localhost:3000")
            .allowed_origin("http://127.0.0.1:5173")
            .allowed_origin("http://127.0.0.1:3000")
            .allowed_methods(vec!["GET", "POST", "PUT", "DELETE", "OPTIONS"])
            .allowed_headers(vec!["Content-Type", "Authorization", "Accept"])
            .supports_credentials()
            .max_age(3600);

        App::new()
            .wrap(cors)
            .wrap(Logger::default())
            .route("/", web::get().to(health_check))
            .route("/health", web::get().to(health_check))
            .route("/api/status", web::get().to(api_status))
    })
    .bind(&bind_address)?
    .run()
    .await
}

async fn health_check() -> actix_web::Result<impl actix_web::Responder> {
    Ok(web::Json(serde_json::json!({
        "status": "healthy",
        "service": "cerberus-hydra-backend",
        "version": env!("CARGO_PKG_VERSION"),
        "timestamp": chrono::Utc::now().to_rfc3339(),
        "heads": {
            "strategy": "active",
            "volume": "monitoring", 
            "security": "protecting"
        }
    })))
}

async fn api_status() -> actix_web::Result<impl actix_web::Responder> {
    Ok(web::Json(serde_json::json!({
        "backend": "healthy",
        "database": "disconnected",
        "helius": "not_configured",
        "bots": {
            "volume": "stopped",
            "bundle": "stopped", 
            "bump": "stopped",
            "sniper": "stopped"
        }
    })))
}