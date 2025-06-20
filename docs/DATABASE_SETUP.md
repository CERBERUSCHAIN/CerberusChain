# 🗄️ Database Setup Guide

## Quick Setup Options

### Option 1: Docker (Recommended for Development)
```bash
# Run the Docker setup script
.\scripts\database\setup-docker.ps1
```

### Option 2: Local PostgreSQL Installation
```bash
# Run the local setup script
.\scripts\database\setup.ps1
```

## Manual Setup (If Scripts Don't Work)

### 1. Install PostgreSQL
- **Windows**: Download from [postgresql.org](https://www.postgresql.org/download/windows/)
- **macOS**: `brew install postgresql`
- **Linux**: `sudo apt-get install postgresql postgresql-contrib`

### 2. Create Database and User
```sql
-- Connect as postgres user
psql -U postgres

-- Create user
CREATE USER cerberus WITH PASSWORD 'CerberusGuard2024!';

-- Create database
CREATE DATABASE cerberus_hydra OWNER cerberus;

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE cerberus_hydra TO cerberus;
```

### 3. Run Migrations
```bash
# From project root
psql -U cerberus -h localhost -p 5432 -d cerberus_hydra -f database/migrations/001_initial_schema.sql
```

### 4. Update .env File
```bash
DATABASE_URL=postgresql://cerberus:CerberusGuard2024!@localhost:5432/cerberus_hydra
```

## Database Schema Overview

### Core Tables:
- **users** - User authentication and management
- **wallets** - Solana wallet storage with encrypted private keys
- **token_holdings** - Token balances for each wallet
- **trades** - Trading history and transaction records
- **bot_configs** - Bot configurations and settings
- **user_sessions** - JWT session management
- **audit_logs** - Security and compliance logging

### Security Features:
- Encrypted private key storage
- Password hashing with Argon2
- Session management with JWT
- Audit logging for all actions
- Account lockout protection

## Testing the Connection

### From Command Line:
```bash
psql -U cerberus -h localhost -p 5432 -d cerberus_hydra
```

### From Backend:
```bash
cd backend
cargo run
# Check logs for "Database connection established"
```

### From Frontend:
Visit `http://localhost:5173` and check the System Status section.

## Troubleshooting

### Common Issues:

1. **Connection Refused**
   - Make sure PostgreSQL is running
   - Check if port 5432 is available
   - Verify DATABASE_URL in .env

2. **Authentication Failed**
   - Check username/password in DATABASE_URL
   - Verify user exists and has correct permissions

3. **Database Not Found**
   - Make sure database was created
   - Check database name in DATABASE_URL

4. **Migration Errors**
   - Check if migration file exists
   - Verify user has CREATE privileges
   - Look for syntax errors in SQL

### Docker Specific:

1. **Container Won't Start**
   ```bash
   docker logs cerberus-postgres
   ```

2. **Port Already in Use**
   ```bash
   docker ps -a
   docker stop <conflicting_container>
   ```

3. **Reset Everything**
   ```bash
   docker stop cerberus-postgres
   docker rm cerberus-postgres
   docker volume rm cerberus_postgres_data
   .\scripts\database\setup-docker.ps1
   ```

## Next Steps

After database setup:
1. ✅ Database is running
2. ✅ Migrations completed
3. ✅ .env file updated
4. 🎯 **Next**: Start the backend server
5. 🎯 **Then**: Test user registration and authentication

**Ready to continue with backend development!**