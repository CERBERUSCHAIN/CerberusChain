# Environment Configuration Guide

## Required Configuration

### 🔑 **Critical Settings (Must Configure)**

```bash
# 1. Database Password (Change this!)
POSTGRES_PASSWORD=your_secure_postgres_password_here

# 2. JWT Secret (Generate a secure random string)
JWT_SECRET=your_super_secure_jwt_secret_key_here

# 3. Helius API Key (Get from https://helius.xyz)
HELIUS_API_KEY=your_helius_api_key_here

# 4. Encryption Key (32 characters exactly)
ENCRYPTION_KEY=your_32_character_encryption_key_here

# 5. Your IP Address (for security)
ALLOWED_IPS=127.0.0.1,your_actual_ip_address_here
```

### 🎯 **How to Get These Values**

#### **Helius API Key**
1. Go to [https://helius.xyz](https://helius.xyz)
2. Sign up for an account
3. Create a new project
4. Copy your API key

#### **Generate Secure Keys**
```bash
# Generate JWT Secret (64+ characters)
openssl rand -base64 64

# Generate Encryption Key (exactly 32 characters)
openssl rand -base64 32 | cut -c1-32
```

#### **Find Your IP Address**
```bash
# Get your public IP
curl -s https://ipinfo.io/ip
```

### 🔒 **Security Settings**
```bash
# Strong PostgreSQL password
POSTGRES_PASSWORD=CerberusGuard2024!SecureDB

# JWT secret (64+ characters)
JWT_SECRET=your_generated_64_character_jwt_secret_here

# Encryption key (exactly 32 characters)
ENCRYPTION_KEY=your_generated_32_char_key_here

# Your IP address for access control
ALLOWED_IPS=127.0.0.1,your.public.ip.address
```

### 📊 **Optional Settings (Can Leave Default)**
- `DEFAULT_SOL_AMOUNT=0.1` - Default trading amount
- `DEFAULT_SLIPPAGE_TOLERANCE=5.0` - Slippage tolerance %
- `RATE_LIMIT_REQUESTS_PER_MINUTE=100` - API rate limiting

## Quick Setup Checklist

- [ ] Set `POSTGRES_PASSWORD`
- [ ] Set `JWT_SECRET` 
- [ ] Set `HELIUS_API_KEY`
- [ ] Set `ENCRYPTION_KEY`
- [ ] Set `ALLOWED_IPS`
- [ ] Save the file

**⚠️ Important:** Never commit your `.env` file to version control!