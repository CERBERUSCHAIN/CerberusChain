# Cerberus Chain: Hydra - Local Development Setup

## 🎉 Complete Local Solution

This setup eliminates ALL network dependencies and Supabase connection issues. Everything runs locally on your machine.

## ✅ What's Included

- **Local PostgreSQL Database** - No network required
- **Complete Database Schema** - All tables and relationships
- **Optimized Configuration** - Tuned for local development
- **Sample Data** - Default admin user and bot configurations
- **Development Scripts** - Easy startup and management

## 🚀 Quick Start

### 1. Initial Setup (Run Once)

```powershell
.\setup-complete-local.ps1
```

### 2. Daily Development

```powershell
.\start-local-dev.ps1
```

### 3. Access the Application

- **Frontend**: <http://localhost:3000>
- **Backend API**: <http://localhost:8080>
- **Database**: localhost:5432

## 🔐 Default Credentials

- **Admin User**:
  - Username: `admin`
  - Password: `CerberusAdmin2024!`

- **Database**:
  - Host: `localhost`
  - Port: `5432`
  - Database: `cerberus_hydra`
  - Username: `cerberus`
  - Password: `CerberusLocal2024!`

## 🛠️ Management Commands

```powershell
# Start database
docker start cerberus-postgres

# Stop database
docker stop cerberus-postgres

# Database shell
docker exec -it cerberus-postgres psql -U cerberus -d cerberus_hydra

# View database logs
docker logs cerberus-postgres

# Reset database (if needed)
docker stop cerberus-postgres
docker rm cerberus-postgres
docker volume rm cerberus_postgres_data
.\setup-complete-local.ps1
```

## 📊 Database Schema

The local database includes all necessary tables:

- **users** - User authentication and management
- **wallets** - Solana wallet storage with encrypted private keys
- **token_holdings** - Token balances for each wallet
- **trades** - Trading history and transaction records
- **bot_configs** - Bot configurations and settings
- **user_sessions** - JWT session management
- **audit_logs** - Security and compliance logging

## ✨ Advantages

- ✅ **No Network Issues** - Everything runs locally
- ✅ **Faster Development** - No network latency
- ✅ **Works Offline** - No internet required
- ✅ **Full Control** - Your data stays on your machine
- ✅ **Easy Debugging** - Direct database access
- ✅ **Perfect for 2 Users** - You and your business partner

## 🔧 Troubleshooting

### Database Won't Start

```powershell
# Check Docker is running
docker --version

# Check container status
docker ps -a

# Restart Docker Desktop if needed
```

### Backend Connection Issues

```powershell
# Check .env file exists
Get-Content .env

# Test database connection
docker exec cerberus-postgres pg_isready -U cerberus -d cerberus_hydra
```

### Frontend Issues

```powershell
# Install dependencies
cd frontend
npm install

# Clear cache and restart
npm run dev
```

## 🎯 Next Steps

1. **Run the setup**: `.\setup-complete-local.ps1`
2. **Start development**: `.\start-local-dev.ps1`
3. **Open browser**: <http://localhost:3000>
4. **Login with admin credentials**
5. **Start building your trading bot features!**

This local setup gives you everything you need without any of the Supabase connection headaches. Perfect for focused development with just you and your business partner.