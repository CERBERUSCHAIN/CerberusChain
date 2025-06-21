//! Authentication handlers

use actix_web::{web, HttpRequest, HttpResponse, Result, HttpMessage};
use sqlx::PgPool;
use uuid::Uuid;
use chrono::Utc;
use std::net::IpAddr;

use crate::database::models::{
    User, CreateUserRequest, LoginRequest, UserResponse, ApiResponse
};
use crate::auth::{AuthService, hash_session_token};

/// Register a new user
pub async fn register(
    pool: web::Data<PgPool>,
    auth_service: web::Data<AuthService>,
    req: web::Json<CreateUserRequest>,
) -> Result<HttpResponse> {
    // Validate password strength
    if let Err(e) = crate::auth::validate_password_strength(&req.password) {
        return Ok(HttpResponse::BadRequest().json(ApiResponse::<()>::error(e.to_string())));
    }

    // Check if username or email already exists
    let existing_user = sqlx::query_as::<_, User>(
        "SELECT * FROM users WHERE username = $1 OR email = $2"
    )
    .bind(&req.username)
    .bind(&req.email)
    .fetch_optional(pool.get_ref())
    .await;

    match existing_user {
        Ok(Some(_)) => {
            return Ok(HttpResponse::Conflict().json(
                ApiResponse::<()>::error("Username or email already exists".to_string())
            ));
        }
        Err(e) => {
            log::error!("Database error during user registration: {}", e);
            return Ok(HttpResponse::InternalServerError().json(
                ApiResponse::<()>::error("Internal server error".to_string())
            ));
        }
        Ok(None) => {}
    }

    // Hash password
    let password_hash = match auth_service.hash_password(&req.password) {
        Ok(hash) => hash,
        Err(e) => {
            log::error!("Password hashing error: {}", e);
            return Ok(HttpResponse::InternalServerError().json(
                ApiResponse::<()>::error("Failed to process password".to_string())
            ));
        }
    };

    // Create user
    let user_id = Uuid::new_v4();
    let result = sqlx::query(
        r#"
        INSERT INTO users (id, username, email, password_hash, is_verified)
        VALUES ($1, $2, $3, $4, $5)
        "#
    )
    .bind(user_id)
    .bind(&req.username)
    .bind(&req.email)
    .bind(&password_hash)
    .bind(false) // Email verification required
    .execute(pool.get_ref())
    .await;

    match result {
        Ok(_) => {
            // Fetch the created user
            let user = sqlx::query_as::<_, User>("SELECT * FROM users WHERE id = $1")
                .bind(user_id)
                .fetch_one(pool.get_ref())
                .await
                .unwrap();

            Ok(HttpResponse::Created().json(ApiResponse::success(UserResponse::from(user))))
        }
        Err(e) => {
            log::error!("Failed to create user: {}", e);
            Ok(HttpResponse::InternalServerError().json(
                ApiResponse::<()>::error("Failed to create user".to_string())
            ))
        }
    }
}

/// Login user and return JWT token
pub async fn login(
    pool: web::Data<PgPool>,
    auth_service: web::Data<AuthService>,
    req: web::Json<LoginRequest>,
    http_req: HttpRequest,
) -> Result<HttpResponse> {
    // Find user by username
    let user = sqlx::query_as::<_, User>("SELECT * FROM users WHERE username = $1 AND is_active = true")
        .bind(&req.username)
        .fetch_optional(pool.get_ref())
        .await;

    let user = match user {
        Ok(Some(user)) => user,
        Ok(None) => {
            return Ok(HttpResponse::Unauthorized().json(
                ApiResponse::<()>::error("Invalid username or password".to_string())
            ));
        }
        Err(e) => {
            log::error!("Database error during login: {}", e);
            return Ok(HttpResponse::InternalServerError().json(
                ApiResponse::<()>::error("Internal server error".to_string())
            ));
        }
    };

    // Check if account is locked
    if let Some(locked_until) = user.locked_until {
        if locked_until > Utc::now() {
            return Ok(HttpResponse::Unauthorized().json(
                ApiResponse::<()>::error("Account is temporarily locked".to_string())
            ));
        }
    }

    // Verify password
    let password_valid = match auth_service.verify_password(&req.password, &user.password_hash) {
        Ok(valid) => valid,
        Err(e) => {
            log::error!("Password verification error: {}", e);
            return Ok(HttpResponse::InternalServerError().json(
                ApiResponse::<()>::error("Authentication error".to_string())
            ));
        }
    };

    if !password_valid {
        // Increment failed login attempts
        let _ = sqlx::query(
            "UPDATE users SET failed_login_attempts = failed_login_attempts + 1 WHERE id = $1"
        )
        .bind(user.id)
        .execute(pool.get_ref())
        .await;

        return Ok(HttpResponse::Unauthorized().json(
            ApiResponse::<()>::error("Invalid username or password".to_string())
        ));
    }

    // Create session
    let session_id = Uuid::new_v4();
    let token = match auth_service.generate_token(&user, session_id) {
        Ok(token) => token,
        Err(e) => {
            log::error!("Token generation error: {}", e);
            return Ok(HttpResponse::InternalServerError().json(
                ApiResponse::<()>::error("Failed to generate token".to_string())
            ));
        }
    };

    // Store session in database
    let token_hash = hash_session_token(&token);
    let ip_address = http_req.peer_addr().map(|addr| addr.ip());
    let user_agent = http_req.headers().get("User-Agent")
        .and_then(|h| h.to_str().ok())
        .map(|s| s.to_string());

    let expires_at = Utc::now() + chrono::Duration::hours(24);

    // Convert IpAddr to string for database storage
    let ip_string = ip_address.map(|ip| ip.to_string());

    let _ = sqlx::query(
        r#"
        INSERT INTO user_sessions (id, user_id, token_hash, ip_address, user_agent, expires_at)
        VALUES ($1, $2, $3, $4, $5, $6)
        "#
    )
    .bind(session_id)
    .bind(user.id)
    .bind(&token_hash)
    .bind(ip_string)
    .bind(user_agent)
    .bind(expires_at)
    .execute(pool.get_ref())
    .await;

    // Update user login info
    let _ = sqlx::query(
        "UPDATE users SET last_login = NOW(), failed_login_attempts = 0 WHERE id = $1"
    )
    .bind(user.id)
    .execute(pool.get_ref())
    .await;

    Ok(HttpResponse::Ok().json(ApiResponse::success(serde_json::json!({
        "token": token,
        "user": UserResponse::from(user),
        "expires_at": expires_at
    }))))
}

/// Logout user (invalidate session)
pub async fn logout(
    pool: web::Data<PgPool>,
    http_req: HttpRequest,
) -> Result<HttpResponse> {
    // Extract token from header
    if let Some(auth_header) = http_req.headers().get("Authorization") {
        if let Ok(auth_str) = auth_header.to_str() {
            if let Ok(token) = crate::auth::extract_token_from_header(auth_str) {
                let token_hash = hash_session_token(token);
                
                // Invalidate session
                let _ = sqlx::query("UPDATE user_sessions SET is_active = false WHERE token_hash = $1")
                    .bind(&token_hash)
                    .execute(pool.get_ref())
                    .await;
            }
        }
    }

    Ok(HttpResponse::Ok().json(ApiResponse::<()>::message("Logged out successfully".to_string())))
}

/// Refresh JWT token
pub async fn refresh_token(
    _pool: web::Data<PgPool>,
    _auth_service: web::Data<AuthService>,
    _http_req: HttpRequest,
) -> Result<HttpResponse> {
    // This would implement token refresh logic
    // For now, return not implemented
    Ok(HttpResponse::NotImplemented().json(
        ApiResponse::<()>::error("Token refresh not implemented yet".to_string())
    ))
}

/// Get current authenticated user
pub async fn get_current_user(
    pool: web::Data<PgPool>,
    http_req: HttpRequest,
) -> Result<HttpResponse> {
    // Extract user from request (set by auth middleware)
    if let Some(claims) = http_req.extensions().get::<crate::database::models::Claims>() {
        let user_id = match Uuid::parse_str(&claims.sub) {
            Ok(id) => id,
            Err(_) => {
                return Ok(HttpResponse::BadRequest().json(
                    ApiResponse::<()>::error("Invalid user ID".to_string())
                ));
            }
        };

        let user = sqlx::query_as::<_, User>("SELECT * FROM users WHERE id = $1")
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
    } else {
        Ok(HttpResponse::Unauthorized().json(
            ApiResponse::<()>::error("Authentication required".to_string())
        ))
    }
}