# 🗄️ Supabase Integration Guide

## ✅ Setup Complete!

Your Supabase Pro account is now integrated with CerberusChain:

### **Connection Details:**
- **Project URL**: https://bervahrnaauhznctodie.supabase.co
- **Plan**: Supabase Pro with Micro Compute
- **Database**: PostgreSQL with 1GB memory, 2-core ARM
- **API**: REST + GraphQL + Real-time subscriptions

## 🔧 **Next Steps**

### **1. Get Your Database Password**
You need to get your database password from Supabase:

1. Go to [Supabase Dashboard](https://supabase.com/dashboard)
2. Select your project: `bervahrnaauhznctodie`
3. Go to **Settings** → **Database**
4. Copy your database password
5. Update your `.env` file:

```bash
DATABASE_URL=postgresql://postgres:[YOUR_DB_PASSWORD]@db.bervahrnaauhznctodie.supabase.co:5432/postgres
```

### **2. Run Database Migration**
The database schema has already been created via Supabase migration. You should see these tables:

- ✅ `users` - User authentication
- ✅ `wallets` - Solana wallet storage  
- ✅ `trades` - Trading history
- ✅ `bot_configs` - Bot configurations
- ✅ `user_sessions` - JWT session management
- ✅ `token_holdings` - Token balances
- ✅ `audit_logs` - Security logging

### **3. Test the Integration**
```bash
# Install frontend dependencies
cd frontend
npm install

# Start frontend
npm run dev

# In another terminal, start backend
cd backend
cargo run
```

Visit `http://localhost:5173` and check the Supabase connection status.

## 🔒 **Security Features**

### **Row Level Security (RLS)**
All tables have RLS enabled with policies that ensure:
- Users can only access their own data
- Proper authentication is required
- Admin users have elevated permissions

### **API Security**
- JWT authentication required for all operations
- Rate limiting on API endpoints
- IP allowlisting for additional security
- Encrypted private key storage

## 📊 **Available APIs**

### **REST API Endpoints**
```bash
# Users
GET    /rest/v1/users
POST   /rest/v1/users
PATCH  /rest/v1/users?id=eq.{id}

# Wallets  
GET    /rest/v1/wallets
POST   /rest/v1/wallets
PATCH  /rest/v1/wallets?id=eq.{id}

# Trades
GET    /rest/v1/trades
POST   /rest/v1/trades
PATCH  /rest/v1/trades?id=eq.{id}

# Bot Configs
GET    /rest/v1/bot_configs
POST   /rest/v1/bot_configs
PATCH  /rest/v1/bot_configs?id=eq.{id}
```

### **Real-time Subscriptions**
```javascript
// Listen for new trades
supabase
  .channel('trades')
  .on('postgres_changes', { 
    event: 'INSERT', 
    schema: 'public', 
    table: 'trades' 
  }, (payload) => {
    console.log('New trade:', payload.new)
  })
  .subscribe()
```

## 💰 **Cost Monitoring**

### **Current Usage Limits**
- **Compute**: $10/month credit (covers Micro instance)
- **Database**: 8GB storage included
- **Bandwidth**: 250GB included
- **API Requests**: Unlimited
- **Users**: 100,000 MAU included

### **Monitoring**
- Check usage in Supabase Dashboard
- Set up billing alerts
- Monitor API request patterns
- Track database growth

## 🚀 **Ready for Development**

Your CerberusChain project now has:
- ✅ Production-grade PostgreSQL database
- ✅ Auto-generated REST APIs
- ✅ Real-time subscriptions
- ✅ Built-in authentication
- ✅ Row Level Security
- ✅ Automatic backups
- ✅ 99.9% uptime SLA

**Next**: Start building your trading bot features! 🤖