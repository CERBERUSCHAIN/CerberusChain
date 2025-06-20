//! Password hashing and verification using Argon2

use argon2::{
    password_hash::{PasswordHash, PasswordHasher, PasswordVerifier, SaltString},
    Argon2
};
use anyhow::{Result, anyhow};
use rand_core::OsRng;

/// Hash a password using Argon2id
pub fn hash_password(password: &str) -> Result<String> {
    if password.len() < 8 {
        return Err(anyhow!("Password must be at least 8 characters long"));
    }

    let salt = SaltString::generate(&mut OsRng);
    let argon2 = Argon2::default();
    
    let password_hash = argon2
        .hash_password(password.as_bytes(), &salt)
        .map_err(|e| anyhow!("Failed to hash password: {}", e))?;

    Ok(password_hash.to_string())
}

/// Verify a password against its hash
pub fn verify_password(password: &str, hash: &str) -> Result<bool> {
    let parsed_hash = PasswordHash::new(hash)
        .map_err(|e| anyhow!("Failed to parse password hash: {}", e))?;

    let argon2 = Argon2::default();
    
    match argon2.verify_password(password.as_bytes(), &parsed_hash) {
        Ok(()) => Ok(true),
        Err(_) => Ok(false),
    }
}

/// Validate password strength
pub fn validate_password_strength(password: &str) -> Result<()> {
    if password.len() < 8 {
        return Err(anyhow!("Password must be at least 8 characters long"));
    }

    if password.len() > 128 {
        return Err(anyhow!("Password must be less than 128 characters"));
    }

    let has_lowercase = password.chars().any(|c| c.is_lowercase());
    let has_uppercase = password.chars().any(|c| c.is_uppercase());
    let has_digit = password.chars().any(|c| c.is_ascii_digit());
    let has_special = password.chars().any(|c| "!@#$%^&*()_+-=[]{}|;:,.<>?".contains(c));

    if !has_lowercase {
        return Err(anyhow!("Password must contain at least one lowercase letter"));
    }

    if !has_uppercase {
        return Err(anyhow!("Password must contain at least one uppercase letter"));
    }

    if !has_digit {
        return Err(anyhow!("Password must contain at least one digit"));
    }

    if !has_special {
        return Err(anyhow!("Password must contain at least one special character"));
    }

    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_password_hashing() {
        let password = "TestPassword123!";
        let hash = hash_password(password).unwrap();
        
        assert!(!hash.is_empty());
        assert!(hash.starts_with("$argon2id$"));
        
        // Verify the password
        assert!(verify_password(password, &hash).unwrap());
        
        // Verify wrong password
        assert!(!verify_password("WrongPassword", &hash).unwrap());
    }

    #[test]
    fn test_password_validation() {
        // Valid password
        assert!(validate_password_strength("TestPassword123!").is_ok());
        
        // Too short
        assert!(validate_password_strength("Test1!").is_err());
        
        // No uppercase
        assert!(validate_password_strength("testpassword123!").is_err());
        
        // No lowercase
        assert!(validate_password_strength("TESTPASSWORD123!").is_err());
        
        // No digit
        assert!(validate_password_strength("TestPassword!").is_err());
        
        // No special character
        assert!(validate_password_strength("TestPassword123").is_err());
    }
}