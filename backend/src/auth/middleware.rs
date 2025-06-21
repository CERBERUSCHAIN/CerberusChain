//! Authentication middleware for protecting routes

use actix_web::{
    dev::{forward_ready, Service, ServiceRequest, ServiceResponse, Transform},
    Error, HttpMessage, HttpResponse,
};
use futures::future::{ok, Ready};
use std::future::Future;
use std::pin::Pin;
use sqlx::PgPool;
use uuid::Uuid;

use crate::auth::{validate_jwt_token, extract_token_from_header};
use crate::database::models::User;

/// Authentication middleware factory
pub struct AuthMiddleware {
    jwt_secret: String,
}

impl AuthMiddleware {
    pub fn new(jwt_secret: String) -> Self {
        Self { jwt_secret }
    }
}

impl<S, B> Transform<S, ServiceRequest> for AuthMiddleware
where
    S: Service<ServiceRequest, Response = ServiceResponse<B>, Error = Error>,
    S::Future: 'static,
    B: 'static,
{
    type Response = ServiceResponse<B>;
    type Error = Error;
    type InitError = ();
    type Transform = AuthMiddlewareService<S>;
    type Future = Ready<Result<Self::Transform, Self::InitError>>;

    fn new_transform(&self, service: S) -> Self::Future {
        ok(AuthMiddlewareService {
            service,
            jwt_secret: self.jwt_secret.clone(),
        })
    }
}

/// Authentication middleware service
pub struct AuthMiddlewareService<S> {
    service: S,
    jwt_secret: String,
}

impl<S, B> Service<ServiceRequest> for AuthMiddlewareService<S>
where
    S: Service<ServiceRequest, Response = ServiceResponse<B>, Error = Error>,
    S::Future: 'static,
    B: 'static,
{
    type Response = ServiceResponse<B>;
    type Error = Error;
    type Future = Pin<Box<dyn Future<Output = Result<Self::Response, Self::Error>>>>;

    forward_ready!(service);

    fn call(&self, req: ServiceRequest) -> Self::Future {
        let jwt_secret = self.jwt_secret.clone();

        // Skip authentication for public routes
        let path = req.path();
        if path == "/health" || path == "/" || path.starts_with("/api/auth/") {
            let fut = self.service.call(req);
            return Box::pin(async move { fut.await });
        }

        // Extract and validate JWT token
        let auth_header = req.headers().get("Authorization");
        
        if let Some(auth_value) = auth_header {
            if let Ok(auth_str) = auth_value.to_str() {
                if let Ok(token) = extract_token_from_header(auth_str) {
                    if let Ok(claims) = validate_jwt_token(token, &jwt_secret) {
                        // Add user info to request extensions
                        req.extensions_mut().insert(claims);
                        
                        let fut = self.service.call(req);
                        return Box::pin(async move { fut.await });
                    }
                }
            }
        }

        // Authentication failed - create proper error response
        let service = self.service.clone();
        Box::pin(async move {
            let (req, _payload) = req.into_parts();
            let response = HttpResponse::Unauthorized()
                .json(serde_json::json!({
                    "success": false,
                    "error": "Authentication required"
                }));
            
            Ok(ServiceResponse::new(req, response))
        })
    }
}

/// Extract authenticated user from request
pub async fn get_authenticated_user(req: &ServiceRequest, pool: &PgPool) -> Result<User, Error> {
    // Get extensions and store in a variable to extend lifetime
    let extensions = req.extensions();
    let claims = extensions.get::<crate::database::models::Claims>()
        .ok_or_else(|| actix_web::error::ErrorUnauthorized("No authentication claims found"))?;

    let user_id = Uuid::parse_str(&claims.sub)
        .map_err(|_| actix_web::error::ErrorBadRequest("Invalid user ID in token"))?;

    let user = sqlx::query_as::<_, User>("SELECT * FROM users WHERE id = $1 AND is_active = true")
        .bind(user_id)
        .fetch_optional(pool)
        .await
        .map_err(|e| actix_web::error::ErrorInternalServerError(format!("Database error: {}", e)))?
        .ok_or_else(|| actix_web::error::ErrorUnauthorized("User not found or inactive"))?;

    Ok(user)
}