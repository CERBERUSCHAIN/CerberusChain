# 🚀 Cerberus Chain: Hydra - Quick Start Guide

## Current Progress: Step 2 - Environment Configuration

### **What You Need to Do Right Now:**

#### **Step 2A: Create Environment File**
**Location**: VS Code Terminal (Bash)
```bash
cp .env.example .env
```

#### **Step 2B: Configure Critical Settings**
**File**: `.env` (in your project root)

**⚠️ IMPORTANT**: You MUST change these 5 settings:

```bash
# 1. Database Password (Change this!)
POSTGRES_PASSWORD=CerberusGuard2024!SecureDB

# 2. JWT Secret (Use this example or generate your own)
JWT_SECRET=CerberusChain2024SuperSecureJWTKeyForAuthenticationAndSecurity123456

# 3. Helius API Key (Get from https://helius.xyz - FREE ACCOUNT)
HELIUS_API_KEY=your_helius_api_key_here

# 4. Encryption Key (Exactly 32 characters)
ENCRYPTION_KEY=CerberusEncryption2024Key123456

# 5. Your IP Address (Find yours at https://whatismyipaddress.com)
ALLOWED_IPS=127.0.0.1,your.actual.ip.here
```

### **How to Get Helius API Key (FREE):**
1. Go to [https://helius.xyz](https://helius.xyz)
2. Click "Sign Up" 
3. Create free account
4. Go to Dashboard → Create Project
5. Copy your API key
6. Paste it in your `.env` file

### **Next Steps After Environment Setup:**
1. Save your `.env` file
2. Run the setup script
3. Install dependencies

**Current Progress**: 25% Complete after this step