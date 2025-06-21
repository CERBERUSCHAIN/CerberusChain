# Fix Supabase Connection with Your Existing Password
# No password reset needed - just fix the username format

Write-Host "🔧 Fixing Supabase Connection (No Password Reset)" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor White
Write-Host ""

Write-Host "📋 The issue is the USERNAME FORMAT, not the password!" -ForegroundColor Yellow
Write-Host "   Your current .env probably has: postgres:password@host" -ForegroundColor Red
Write-Host "   But Supabase needs: postgres.bervahrnaauhznctodie:password@host" -ForegroundColor Green
Write-Host ""

# Check current .env
if (Test-Path ".env") {
    $envContent = Get-Content ".env" -Raw
    $databaseLine = $envContent -split "`n" | Where-Object { $_ -match "^DATABASE_URL=" }
    
    if ($databaseLine) {
        Write-Host "📋 Current DATABASE_URL:" -ForegroundColor Yellow
        Write-Host "   $databaseLine" -ForegroundColor Gray
        
        # Extract the password from current URL
        if ($databaseLine -match ":([^@]+)@") {
            $existingPassword = $matches[1]
            Write-Host "✅ Found existing password in .env" -ForegroundColor Green
            
            # Create the CORRECT URL with proper username format
            $fixedUrl = "postgresql://postgres.bervahrnaauhznctodie:$existingPassword@aws-0-us-west-1.pooler.supabase.com:6543/postgres"
            
            Write-Host ""
            Write-Host "🔧 Applying username format fix..." -ForegroundColor Yellow
            
            # Update the DATABASE_URL
            $envContent = $envContent -replace "DATABASE_URL=.*", "DATABASE_URL=$fixedUrl"
            $envContent | Set-Content ".env" -NoNewline
            
            Write-Host "✅ Fixed DATABASE_URL with correct username format!" -ForegroundColor Green
            Write-Host ""
            Write-Host "📋 Changes made:" -ForegroundColor Cyan
            Write-Host "   ✅ Username: postgres → postgres.bervahrnaauhznctodie" -ForegroundColor Green
            Write-Host "   ✅ Host: Using pooler for better reliability" -ForegroundColor Green
            Write-Host "   ✅ Password: Kept your existing password" -ForegroundColor Green
            
        } else {
            Write-Host "❌ Could not extract password from current DATABASE_URL" -ForegroundColor Red
            Write-Host "📝 Please enter your existing Supabase password:" -ForegroundColor Yellow
            $password = Read-Host "Password"
            
            $fixedUrl = "postgresql://postgres.bervahrnaauhznctodie:$password@aws-0-us-west-1.pooler.supabase.com:6543/postgres"
            $envContent = $envContent -replace "DATABASE_URL=.*", "DATABASE_URL=$fixedUrl"
            $envContent | Set-Content ".env" -NoNewline
            
            Write-Host "✅ Fixed DATABASE_URL with your password!" -ForegroundColor Green
        }
    } else {
        Write-Host "❌ No DATABASE_URL found in .env file" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "❌ .env file not found" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "🎉 Connection Fixed!" -ForegroundColor Green
Write-Host ""
Write-Host "🔍 The key fix:" -ForegroundColor Yellow
Write-Host "   Your project ID must be part of the username with a DOT" -ForegroundColor White
Write-Host "   postgres.bervahrnaauhznctodie (not postgres:)" -ForegroundColor Green
Write-Host ""
Write-Host "🚀 Now test the backend:" -ForegroundColor Cyan
Write-Host "   cd backend" -ForegroundColor White
Write-Host "   cargo run" -ForegroundColor White
Write-Host ""
Write-Host "💡 Expected result:" -ForegroundColor Yellow
Write-Host "   ✅ Database connection established" -ForegroundColor Green
Write-Host "   🚀 Server starting on 0.0.0.0:8080" -ForegroundColor Green
Write-Host ""
Write-Host "🎯 This should fix the 'Tenant or user not found' error!" -ForegroundColor Magenta