//! Trading handlers

use actix_web::{web, HttpResponse, Result};
use sqlx::PgPool;
use uuid::Uuid;

use crate::database::models::{Trade, ApiResponse, CreateTradeRequest, PaginationParams};

/// List user's trades
pub async fn list_trades(
    pool: web::Data<PgPool>,
    query: web::Query<PaginationParams>,
) -> Result<HttpResponse> {
    // TODO: Extract user ID from JWT token and implement pagination
    let trades: Vec<Trade> = vec![];
    Ok(HttpResponse::Ok().json(ApiResponse::success(trades)))
}

/// Create new trade
pub async fn create_trade(
    pool: web::Data<PgPool>,
    req: web::Json<CreateTradeRequest>,
) -> Result<HttpResponse> {
    // TODO: Implement trade creation with Solana transaction
    Ok(HttpResponse::NotImplemented().json(
        ApiResponse::<()>::error("Trade creation not implemented yet".to_string())
    ))
}

/// Get trade by ID
pub async fn get_trade(
    pool: web::Data<PgPool>,
    path: web::Path<Uuid>,
) -> Result<HttpResponse> {
    let trade_id = path.into_inner();

    let trade = sqlx::query_as::<_, Trade>("SELECT * FROM trades WHERE id = $1")
        .bind(trade_id)
        .fetch_optional(pool.get_ref())
        .await;

    match trade {
        Ok(Some(trade)) => {
            Ok(HttpResponse::Ok().json(ApiResponse::success(trade)))
        }
        Ok(None) => {
            Ok(HttpResponse::NotFound().json(
                ApiResponse::<()>::error("Trade not found".to_string())
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

/// Cancel trade
pub async fn cancel_trade(
    pool: web::Data<PgPool>,
    path: web::Path<Uuid>,
) -> Result<HttpResponse> {
    let trade_id = path.into_inner();

    let result = sqlx::query("UPDATE trades SET status = 'cancelled' WHERE id = $1 AND status = 'pending'")
        .bind(trade_id)
        .execute(pool.get_ref())
        .await;

    match result {
        Ok(result) => {
            if result.rows_affected() > 0 {
                Ok(HttpResponse::Ok().json(
                    ApiResponse::<()>::message("Trade cancelled successfully".to_string())
                ))
            } else {
                Ok(HttpResponse::NotFound().json(
                    ApiResponse::<()>::error("Trade not found or cannot be cancelled".to_string())
                ))
            }
        }
        Err(e) => {
            log::error!("Failed to cancel trade: {}", e);
            Ok(HttpResponse::InternalServerError().json(
                ApiResponse::<()>::error("Failed to cancel trade".to_string())
            ))
        }
    }
}