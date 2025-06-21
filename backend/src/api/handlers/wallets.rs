//! Wallet management handlers

use actix_web::{web, HttpResponse, Result};
use sqlx::PgPool;
use uuid::Uuid;

use crate::database::models::{Wallet, WalletResponse, ApiResponse, CreateWalletRequest};

/// List user's wallets
pub async fn list_wallets(
    pool: web::Data<PgPool>,
) -> Result<HttpResponse> {
    // TODO: Extract user ID from JWT token
    // For now, return empty list
    let wallets: Vec<WalletResponse> = vec![];
    Ok(HttpResponse::Ok().json(ApiResponse::success(wallets)))
}

/// Create new wallet
pub async fn create_wallet(
    pool: web::Data<PgPool>,
    req: web::Json<CreateWalletRequest>,
) -> Result<HttpResponse> {
    // TODO: Implement wallet creation with Solana keypair generation
    Ok(HttpResponse::NotImplemented().json(
        ApiResponse::<()>::error("Wallet creation not implemented yet".to_string())
    ))
}

/// Get wallet by ID
pub async fn get_wallet(
    pool: web::Data<PgPool>,
    path: web::Path<Uuid>,
) -> Result<HttpResponse> {
    let wallet_id = path.into_inner();

    let wallet = sqlx::query_as::<_, Wallet>(
        "SELECT * FROM wallets WHERE id = $1 AND is_active = true"
    )
    .bind(wallet_id)
    .fetch_optional(pool.get_ref())
    .await;

    match wallet {
        Ok(Some(wallet)) => {
            Ok(HttpResponse::Ok().json(ApiResponse::success(WalletResponse::from(wallet))))
        }
        Ok(None) => {
            Ok(HttpResponse::NotFound().json(
                ApiResponse::<()>::error("Wallet not found".to_string())
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

/// Update wallet
pub async fn update_wallet(
    pool: web::Data<PgPool>,
    path: web::Path<Uuid>,
    req: web::Json<serde_json::Value>,
) -> Result<HttpResponse> {
    Ok(HttpResponse::NotImplemented().json(
        ApiResponse::<()>::error("Wallet update not implemented yet".to_string())
    ))
}

/// Delete wallet
pub async fn delete_wallet(
    pool: web::Data<PgPool>,
    path: web::Path<Uuid>,
) -> Result<HttpResponse> {
    let wallet_id = path.into_inner();

    let result = sqlx::query("UPDATE wallets SET is_active = false WHERE id = $1")
        .bind(wallet_id)
        .execute(pool.get_ref())
        .await;

    match result {
        Ok(result) => {
            if result.rows_affected() > 0 {
                Ok(HttpResponse::Ok().json(
                    ApiResponse::<()>::message("Wallet deleted successfully".to_string())
                ))
            } else {
                Ok(HttpResponse::NotFound().json(
                    ApiResponse::<()>::error("Wallet not found".to_string())
                ))
            }
        }
        Err(e) => {
            log::error!("Failed to delete wallet: {}", e);
            Ok(HttpResponse::InternalServerError().json(
                ApiResponse::<()>::error("Failed to delete wallet".to_string())
            ))
        }
    }
}

/// Get wallet balance
pub async fn get_balance(
    pool: web::Data<PgPool>,
    path: web::Path<Uuid>,
) -> Result<HttpResponse> {
    Ok(HttpResponse::NotImplemented().json(
        ApiResponse::<()>::error("Balance checking not implemented yet".to_string())
    ))
}

/// Get wallet token holdings
pub async fn get_token_holdings(
    pool: web::Data<PgPool>,
    path: web::Path<Uuid>,
) -> Result<HttpResponse> {
    Ok(HttpResponse::NotImplemented().json(
        ApiResponse::<()>::error("Token holdings not implemented yet".to_string())
    ))
}