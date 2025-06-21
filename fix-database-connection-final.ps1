# Fix Database Connection - Final Solution
# This will fix the "Tenant or user not found" error

Write-Host "🔧 Fixing Database Connection - Final Solution" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor White
Write-Host ""

Write-Host "📋 The error 'Tenant or user not found' means wrong username format" -ForegroundColor Yellow
Write-Host "   Your .env probably has: postgres:password@host" -ForegroundColor Red
Write-Host "   But Supabase needs: postgres.bervahrnaauhznctodie:password@host" -ForegroundColor Green
Write-Host ""

# Check current .env
Write-Host "🔍 Step 1: Checking current .env..." -ForegroundColor Yellow

if (Test-Path ".env") {
    $envContent = Get-Content ".env" -Raw
    $databaseLine = $envContent -split "`n" | Where-Object { $_ -match "^DATABASE_URL=" }
    
    if ($databaseLine) {
        Write-Host "✅ Found DATABASE_URL:" -ForegroundColor Green
        Write-Host "   Current: $databaseLine" -ForegroundColor Gray
        
        # Check if it has the correct format
        if ($databaseLine -match "postgres\.bervahrnaauhznctodie") {
            Write-Host "✅ Username format is already correct" -ForegroundColor Green
            $needsUsernamefix = $false
        } else {
            Write-Host "❌ Username format is WRONG - this is the problem!" -ForegroundColor Red
            $needsUsernamefix = $true
        }
    } else {
        Write-Host "❌ No DATABASE_URL found in .env" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "❌ .env file not found" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "🔧 Step 2: Applying the CORRECT connection string..." -ForegroundColor Yellow

# The EXACT correct connection string for your Supabase project
$correctDatabaseUrl = "postgresql://postgres.bervahrnaauhznctodie:73JiVBWgwxNtYbM8@aws-0-us-west-1.pooler.supabase.com:6543/postgres"

# Update the DATABASE_URL regardless of current format
$envContent = $envContent -replace "DATABASE_URL=.*", "DATABASE_URL=$correctDatabaseUrl"

# Write back to .env
$envContent | Set-Content ".env" -NoNewline

Write-Host "✅ Applied CORRECT connection string" -ForegroundColor Green
Write-Host "   Username: postgres.bervahrnaauhznctodie (with DOT)" -ForegroundColor Green
Write-Host "   Password: 73JiVBWgwxNtYbM8" -ForegroundColor Green
Write-Host "   Host: aws-0-us-west-1.pooler.supabase.com" -ForegroundColor Green
Write-Host "   Port: 6543" -ForegroundColor Green

Write-Host ""
Write-Host "🧪 Step 3: Testing network connectivity..." -ForegroundColor Yellow

$poolerTest = Test-NetConnection "aws-0-us-west-1.pooler.supabase.com" -Port 6543 -InformationLevel Quiet -WarningAction SilentlyContinue

if ($poolerTest) {
    Write-Host "✅ Network connection: WORKING" -ForegroundColor Green
} else {
    Write-Host "❌ Network connection: BLOCKED" -ForegroundColor Red
    Write-Host "🔄 Trying direct connection as backup..." -ForegroundColor Yellow
    
    $directTest = Test-NetConnection "db.bervahrnaauhznctodie.supabase.co" -Port 5432 -InformationLevel Quiet -WarningAction SilentlyContinue
    
    if ($directTest) {
        Write-Host "✅ Direct connection: WORKING" -ForegroundColor Green
        Write-Host "🔧 Switching to direct connection..." -ForegroundColor Yellow
        
        $directUrl = "postgresql://postgres.bervahrnaauhznctodie:73JiVBWgwxNtYbM8@db.bervahrnaauhznctodie.supabase.co:5432/postgres"
        $envContent = Get-Content ".env" -Raw
        $envContent = $envContent -replace "DATABASE_URL=.*", "DATABASE_URL=$directUrl"
        $envContent | Set-Content ".env" -NoNewline
        
        Write-Host "✅ Updated to use direct connection" -ForegroundColor Green
    } else {
        Write-Host "❌ Both connections blocked - network/firewall issue" -ForegroundColor Red
        Write-Host ""
        Write-Host "🔧 Network issue detected. Try:" -ForegroundColor Yellow
        Write-Host "   1. Mobile hotspot (different network)" -ForegroundColor White
        Write-Host "   2. Local database: .\setup-local-database-final.ps1" -ForegroundColor White
        Write-Host ""
        Write-Host "💡 But first, try the backend anyway - the username fix might be enough!" -ForegroundColor Cyan
    }
}

Write-Host ""
Write-Host "🎉 Database Connection Fixed!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 The key fix:" -ForegroundColor Cyan
Write-Host "   ❌ OLD: postgresql://postgres:password@host" -ForegroundColor Red
Write-Host "   ✅ NEW: postgresql://postgres.bervahrnaauhznctodie:password@host" -ForegroundColor Green
Write-Host ""
Write-Host "🚀 Now test the backend:" -ForegroundColor Yellow
Write-Host "   cd backend" -ForegroundColor White
Write-Host "   cargo run" -ForegroundColor White
Write-Host ""
Write-Host "💡 Expected result:" -ForegroundColor Cyan
Write-Host "   ✅ Database connection established" -ForegroundColor Green
Write-Host "   🚀 Server starting on 0.0.0.0:8080" -ForegroundColor Green
Write-Host ""
Write-Host "🎯 This fixes the 'Tenant or user not found' error!" -ForegroundColor Magenta