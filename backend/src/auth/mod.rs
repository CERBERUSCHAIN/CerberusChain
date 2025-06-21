//! Authentication module for Cerberus Chain: Hydra
//! Handles JWT tokens, password hashing, and user authentication

pub mod jwt;
pub mod password;
pub mod middleware;

pub use jwt::*;
pub use password::*;
pub use middleware::*;

use crate::database::models::{User, Claims};
use anyhow::Result;
use uuid::Uuid;

/// Authentication service
#[derive(Clone)]
pub struct AuthService {
    jwt_secret: String,
    token_expiration_hours: u64,
}

impl AuthService {
    pub fn new(jwt_secret: String, token_expiration_hours: u64) -> Self {
        Self {
            jwt_secret,
            token_expiration_hours,
        }
    }

    /// Generate JWT token for user
    pub fn generate_token(&self, user: &User, session_id: Uuid) -> Result<String> {
        generate_jwt_token(user, session_id, &self.jwt_secret, self.token_expiration_hours)
    }

    /// Validate JWT token
    pub fn validate_token(&self, token: &str) -> Result<Claims> {
        validate_jwt_token(token, &self.jwt_secret)
    }

    /// Hash password
    pub fn hash_password(&self, password: &str) -> Result<String> {
        hash_password(password)
    }

    /// Verify password
    pub fn verify_password(&self, password: &str, hash: &str) -> Result<bool> {
        verify_password(password, hash)
    }
}