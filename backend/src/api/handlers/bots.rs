//! Bot management handlers

use actix_web::{web, HttpResponse, Result};
use sqlx::PgPool;
use uuid::Uuid;

use crate::database::models::{BotConfig, ApiResponse, CreateBotConfigRequest};

/// List user's bot configurations
pub async fn list_bot_configs(
    pool: web::Data<PgPool>,
) -> Result<HttpResponse> {
    // TODO: Extract user ID from JWT token
    let bots: Vec<BotConfig> = vec![];
    Ok(HttpResponse::Ok().json(ApiResponse::success(bots)))
}

/// Create new bot configuration
pub async fn create_bot_config(
    pool: web::Data<PgPool>,
    req: web::Json<CreateBotConfigRequest>,
) -> Result<HttpResponse> {
    // TODO: Implement bot configuration creation
    Ok(HttpResponse::NotImplemented().json(
        ApiResponse::<()>::error("Bot creation not implemented yet".to_string())
    ))
}

/// Get bot configuration by ID
pub async fn get_bot_config(
    pool: web::Data<PgPool>,
    path: web::Path<Uuid>,
) -> Result<HttpResponse> {
    let bot_id = path.into_inner();

    let bot = sqlx::query_as::<_, BotConfig>("SELECT * FROM bot_configs WHERE id = $1")
        .bind(bot_id)
        .fetch_optional(pool.get_ref())
        .await;

    match bot {
        Ok(Some(bot)) => {
            Ok(HttpResponse::Ok().json(ApiResponse::success(bot)))
        }
        Ok(None) => {
            Ok(HttpResponse::NotFound().json(
                ApiResponse::<()>::error("Bot configuration not found".to_string())
            ))
        }
        Err(e) => {
            log::error!("Database error: {}", e);
            Ok(HttpResponse::InternalServerError().json(
                ApiResponse::<()>::error("Internal server error".to_string())
            ))
        }
    }
}

/// Update bot configuration
pub async fn update_bot_config(
    pool: web::Data<PgPool>,
    path: web::Path<Uuid>,
    req: web::Json<serde_json::Value>,
) -> Result<HttpResponse> {
    Ok(HttpResponse::NotImplemented().json(
        ApiResponse::<()>::error("Bot update not implemented yet".to_string())
    ))
}

/// Delete bot configuration
pub async fn delete_bot_config(
    pool: web::Data<PgPool>,
    path: web::Path<Uuid>,
) -> Result<HttpResponse> {
    let bot_id = path.into_inner();

    let result = sqlx::query("DELETE FROM bot_configs WHERE id = $1")
        .bind(bot_id)
        .execute(pool.get_ref())
        .await;

    match result {
        Ok(result) => {
            if result.rows_affected() > 0 {
                Ok(HttpResponse::Ok().json(
                    ApiResponse::<()>::message("Bot configuration deleted successfully".to_string())
                ))
            } else {
                Ok(HttpResponse::NotFound().json(
                    ApiResponse::<()>::error("Bot configuration not found".to_string())
                ))
            }
        }
        Err(e) => {
            log::error!("Failed to delete bot configuration: {}", e);
            Ok(HttpResponse::InternalServerError().json(
                ApiResponse::<()>::error("Failed to delete bot configuration".to_string())
            ))
        }
    }
}

/// Start bot
pub async fn start_bot(
    pool: web::Data<PgPool>,
    path: web::Path<Uuid>,
) -> Result<HttpResponse> {
    let bot_id = path.into_inner();

    let result = sqlx::query("UPDATE bot_configs SET is_active = true WHERE id = $1")
        .bind(bot_id)
        .execute(pool.get_ref())
        .await;

    match result {
        Ok(result) => {
            if result.rows_affected() > 0 {
                Ok(HttpResponse::Ok().json(
                    ApiResponse::<()>::message("Bot started successfully".to_string())
                ))
            } else {
                Ok(HttpResponse::NotFound().json(
                    ApiResponse::<()>::error("Bot configuration not found".to_string())
                ))
            }
        }
        Err(e) => {
            log::error!("Failed to start bot: {}", e);
            Ok(HttpResponse::InternalServerError().json(
                ApiResponse::<()>::error("Failed to start bot".to_string())
            ))
        }
    }
}

/// Stop bot
pub async fn stop_bot(
    pool: web::Data<PgPool>,
    path: web::Path<Uuid>,
) -> Result<HttpResponse> {
    let bot_id = path.into_inner();

    let result = sqlx::query("UPDATE bot_configs SET is_active = false WHERE id = $1")
        .bind(bot_id)
        .execute(pool.get_ref())
        .await;

    match result {
        Ok(result) => {
            if result.rows_affected() > 0 {
                Ok(HttpResponse::Ok().json(
                    ApiResponse::<()>::message("Bot stopped successfully".to_string())
                ))
            } else {
                Ok(HttpResponse::NotFound().json(
                    ApiResponse::<()>::error("Bot configuration not found".to_string())
                ))
            }
        }
        Err(e) => {
            log::error!("Failed to stop bot: {}", e);
            Ok(HttpResponse::InternalServerError().json(
                ApiResponse::<()>::error("Failed to stop bot".to_string())
            ))
        }
    }
}

/// Get bot status
pub async fn get_bot_status(
    pool: web::Data<PgPool>,
    path: web::Path<Uuid>,
) -> Result<HttpResponse> {
    let bot_id = path.into_inner();

    let bot = sqlx::query_as::<_, BotConfig>("SELECT * FROM bot_configs WHERE id = $1")
        .bind(bot_id)
        .fetch_optional(pool.get_ref())
        .await;

    match bot {
        Ok(Some(bot)) => {
            Ok(HttpResponse::Ok().json(ApiResponse::success(serde_json::json!({
                "id": bot.id,
                "name": bot.name,
                "bot_type": bot.bot_type,
                "is_active": bot.is_active,
                "last_run": bot.last_run,
                "status": if bot.is_active { "running" } else { "stopped" }
            }))))
        }
        Ok(None) => {
            Ok(HttpResponse::NotFound().json(
                ApiResponse::<()>::error("Bot configuration not found".to_string())
            ))
        }
        Err(e) => {
            log::error!("Database error: {}", e);
            Ok(HttpResponse::InternalServerError().json(
                ApiResponse::<()>::error("Internal server error".to_string())
            ))
        }
    }
}