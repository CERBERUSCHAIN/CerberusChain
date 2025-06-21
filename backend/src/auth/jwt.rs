//! JWT token management for Cerberus Chain: Hydra

use crate::database::models::{User, Claims};
use jsonwebtoken::{encode, decode, Header, Validation, EncodingKey, DecodingKey};
use anyhow::{Result, anyhow};
use uuid::Uuid;
use chrono::{Utc, Duration};
use sha2::{Sha256, Digest};

/// Generate JWT token for authenticated user
pub fn generate_jwt_token(
    user: &User, 
    session_id: Uuid, 
    secret: &str, 
    expiration_hours: u64
) -> Result<String> {
    let now = Utc::now();
    let expiration = now + Duration::hours(expiration_hours as i64);

    let claims = Claims {
        sub: user.id.to_string(),
        username: user.username.clone(),
        exp: expiration.timestamp() as usize,
        iat: now.timestamp() as usize,
        session_id: session_id.to_string(),
    };

    let token = encode(
        &Header::default(),
        &claims,
        &EncodingKey::from_secret(secret.as_ref()),
    )?;

    Ok(token)
}

/// Validate JWT token and extract claims
pub fn validate_jwt_token(token: &str, secret: &str) -> Result<Claims> {
    let token_data = decode::<Claims>(
        token,
        &DecodingKey::from_secret(secret.as_ref()),
        &Validation::default(),
    )?;

    // Check if token is expired
    let now = Utc::now().timestamp() as usize;
    if token_data.claims.exp < now {
        return Err(anyhow!("Token has expired"));
    }

    Ok(token_data.claims)
}

/// Extract token from Authorization header
pub fn extract_token_from_header(auth_header: &str) -> Result<&str> {
    if !auth_header.starts_with("Bearer ") {
        return Err(anyhow!("Invalid authorization header format"));
    }

    let token = &auth_header[7..]; // Remove "Bearer " prefix
    if token.is_empty() {
        return Err(anyhow!("Empty token"));
    }

    Ok(token)
}

/// Generate session ID hash for database storage
pub fn hash_session_token(token: &str) -> String {
    let mut hasher = Sha256::new();
    hasher.update(token.as_bytes());
    hex::encode(hasher.finalize())
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::database::models::User;
    use chrono::Utc;

    fn create_test_user() -> User {
        User {
            id: Uuid::new_v4(),
            username: "testuser".to_string(),
            email: "test@example.com".to_string(),
            password_hash: "hash".to_string(),
            created_at: Utc::now(),
            updated_at: Utc::now(),
            last_login: None,
            is_active: true,
            is_verified: true,
            failed_login_attempts: 0,
            locked_until: None,
        }
    }

    #[test]
    fn test_jwt_generation_and_validation() {
        let user = create_test_user();
        let session_id = Uuid::new_v4();
        let secret = "test_secret";
        let expiration_hours = 24;

        // Generate token
        let token = generate_jwt_token(&user, session_id, secret, expiration_hours).unwrap();
        assert!(!token.is_empty());

        // Validate token
        let claims = validate_jwt_token(&token, secret).unwrap();
        assert_eq!(claims.sub, user.id.to_string());
        assert_eq!(claims.username, user.username);
        assert_eq!(claims.session_id, session_id.to_string());
    }

    #[test]
    fn test_token_extraction() {
        let auth_header = "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9";
        let token = extract_token_from_header(auth_header).unwrap();
        assert_eq!(token, "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9");

        // Test invalid header
        let invalid_header = "Invalid header";
        assert!(extract_token_from_header(invalid_header).is_err());
    }
}