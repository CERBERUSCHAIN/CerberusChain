# SIMPLE SSH Setup - No fancy stuff, just what works
# Run this as Administrator

Write-Host "Setting up SSH Agent (Simple Method)..." -ForegroundColor Cyan

# Method 1: Start the service
Write-Host "Starting SSH Agent service..." -ForegroundColor Yellow
try {
    Start-Service ssh-agent
    Set-Service -Name ssh-agent -StartupType Automatic
    Write-Host "SSH Agent service started successfully" -ForegroundColor Green
} catch {
    Write-Host "Failed to start SSH Agent service: $($_.Exception.Message)" -ForegroundColor Red
}

# Method 2: Add the key
Write-Host "Adding SSH key (you'll need to enter passphrase)..." -ForegroundColor Yellow
ssh-add "C:\Users\lowke\.ssh\id_rsa"

# Test it
Write-Host "Testing SSH agent..." -ForegroundColor Yellow
ssh-add -l