//! API module for Cerberus Chain: Hydra
//! Contains all HTTP endpoints and route handlers

pub mod handlers;

use actix_web::web;

/// Configure all API routes
pub fn configure_routes(cfg: &mut web::ServiceConfig) {
    cfg.service(
        web::scope("/api")
            .configure(auth_routes)
            .configure(user_routes)
            .configure(wallet_routes)
            .configure(trade_routes)
            .configure(bot_routes)
    );
}

/// Configure authentication routes
fn auth_routes(cfg: &mut web::ServiceConfig) {
    cfg.service(
        web::scope("/auth")
            .route("/register", web::post().to(handlers::auth::register))
            .route("/login", web::post().to(handlers::auth::login))
            .route("/logout", web::post().to(handlers::auth::logout))
            .route("/refresh", web::post().to(handlers::auth::refresh_token))
            .route("/me", web::get().to(handlers::auth::get_current_user))
    );
}

/// Configure user management routes
fn user_routes(cfg: &mut web::ServiceConfig) {
    cfg.service(
        web::scope("/users")
            .route("", web::get().to(handlers::users::list_users))
            .route("/{id}", web::get().to(handlers::users::get_user))
            .route("/{id}", web::put().to(handlers::users::update_user))
            .route("/{id}", web::delete().to(handlers::users::delete_user))
    );
}

/// Configure wallet management routes
fn wallet_routes(cfg: &mut web::ServiceConfig) {
    cfg.service(
        web::scope("/wallets")
            .route("", web::get().to(handlers::wallets::list_wallets))
            .route("", web::post().to(handlers::wallets::create_wallet))
            .route("/{id}", web::get().to(handlers::wallets::get_wallet))
            .route("/{id}", web::put().to(handlers::wallets::update_wallet))
            .route("/{id}", web::delete().to(handlers::wallets::delete_wallet))
            .route("/{id}/balance", web::get().to(handlers::wallets::get_balance))
            .route("/{id}/tokens", web::get().to(handlers::wallets::get_token_holdings))
    );
}

/// Configure trading routes
fn trade_routes(cfg: &mut web::ServiceConfig) {
    cfg.service(
        web::scope("/trades")
            .route("", web::get().to(handlers::trades::list_trades))
            .route("", web::post().to(handlers::trades::create_trade))
            .route("/{id}", web::get().to(handlers::trades::get_trade))
            .route("/{id}/cancel", web::post().to(handlers::trades::cancel_trade))
    );
}

/// Configure bot management routes
fn bot_routes(cfg: &mut web::ServiceConfig) {
    cfg.service(
        web::scope("/bots")
            .route("", web::get().to(handlers::bots::list_bot_configs))
            .route("", web::post().to(handlers::bots::create_bot_config))
            .route("/{id}", web::get().to(handlers::bots::get_bot_config))
            .route("/{id}", web::put().to(handlers::bots::update_bot_config))
            .route("/{id}", web::delete().to(handlers::bots::delete_bot_config))
            .route("/{id}/start", web::post().to(handlers::bots::start_bot))
            .route("/{id}/stop", web::post().to(handlers::bots::stop_bot))
            .route("/{id}/status", web::get().to(handlers::bots::get_bot_status))
    );
}