//! User management handlers

use actix_web::{web, HttpResponse, Result};
use sqlx::PgPool;
use uuid::Uuid;

use crate::database::models::{User, UserResponse, ApiResponse, PaginationParams};

/// List all users (admin only)
pub async fn list_users(
    pool: web::Data<PgPool>,
    query: web::Query<PaginationParams>,
) -> Result<HttpResponse> {
    let page = query.page.unwrap_or(1);
    let limit = query.limit.unwrap_or(20);
    let offset = (page - 1) * limit;

    let users = sqlx::query_as::<_, User>(
        "SELECT * FROM users WHERE is_active = true ORDER BY created_at DESC LIMIT $1 OFFSET $2"
    )
    .bind(limit as i64)
    .bind(offset as i64)
    .fetch_all(pool.get_ref())
    .await;

    match users {
        Ok(users) => {
            let user_responses: Vec<UserResponse> = users.into_iter().map(UserResponse::from).collect();
            Ok(HttpResponse::Ok().json(ApiResponse::success(user_responses)))
        }
        Err(e) => {
            log::error!("Failed to fetch users: {}", e);
            Ok(HttpResponse::InternalServerError().json(
                ApiResponse::<()>::error("Failed to fetch users".to_string())
            ))
        }
    }
}

/// Get user by ID
pub async fn get_user(
    pool: web::Data<PgPool>,
    path: web::Path<Uuid>,
) -> Result<HttpResponse> {
    let user_id = path.into_inner();

    let user = sqlx::query_as::<_, User>("SELECT * FROM users WHERE id = $1 AND is_active = true")
        .bind(user_id)
        .fetch_optional(pool.get_ref())
        .await;

    match user {
        Ok(Some(user)) => {
            Ok(HttpResponse::Ok().json(ApiResponse::success(UserResponse::from(user))))
        }
        Ok(None) => {
            Ok(HttpResponse::NotFound().json(
                ApiResponse::<()>::error("User not found".to_string())
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

/// Update user
pub async fn update_user(
    pool: web::Data<PgPool>,
    path: web::Path<Uuid>,
    req: web::Json<serde_json::Value>,
) -> Result<HttpResponse> {
    let user_id = path.into_inner();

    // For now, just return not implemented
    Ok(HttpResponse::NotImplemented().json(
        ApiResponse::<()>::error("User update not implemented yet".to_string())
    ))
}

/// Delete user (soft delete)
pub async fn delete_user(
    pool: web::Data<PgPool>,
    path: web::Path<Uuid>,
) -> Result<HttpResponse> {
    let user_id = path.into_inner();

    let result = sqlx::query("UPDATE users SET is_active = false WHERE id = $1")
        .bind(user_id)
        .execute(pool.get_ref())
        .await;

    match result {
        Ok(result) => {
            if result.rows_affected() > 0 {
                Ok(HttpResponse::Ok().json(
                    ApiResponse::<()>::message("User deleted successfully".to_string())
                ))
            } else {
                Ok(HttpResponse::NotFound().json(
                    ApiResponse::<()>::error("User not found".to_string())
                ))
            }
        }
        Err(e) => {
            log::error!("Failed to delete user: {}", e);
            Ok(HttpResponse::InternalServerError().json(
                ApiResponse::<()>::error("Failed to delete user".to_string())
            ))
        }
    }
}