# Fixed SSH Agent Setup for Windows
# Run this as Administrator if possible

Write-Host "🔧 Fixing SSH Agent setup..." -ForegroundColor Cyan

# Method 1: Try Windows OpenSSH
Write-Host "📋 Checking OpenSSH installation..." -ForegroundColor Yellow

# Check if OpenSSH is installed
$openssh = Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH*'
Write-Host "OpenSSH Status:" -ForegroundColor Gray
$openssh | Format-Table

# Install OpenSSH if missing
if ($openssh | Where-Object State -eq 'NotPresent') {
    Write-Host "⚠️  Installing OpenSSH..." -ForegroundColor Yellow
    Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0
    Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
}

# Start SSH Agent service
Write-Host "🔄 Starting SSH Agent service..." -ForegroundColor Yellow
try {
    Start-Service ssh-agent -ErrorAction Stop
    Set-Service -Name ssh-agent -StartupType Automatic
    Write-Host "✅ SSH Agent service started" -ForegroundColor Green
} catch {
    Write-Host "❌ SSH Agent service failed to start" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

# Try adding the key
Write-Host "🔑 Attempting to add SSH key..." -ForegroundColor Yellow
Write-Host "You should be prompted for your passphrase..." -ForegroundColor Gray

try {
    ssh-add "C:\Users\lowke\.ssh\id_rsa"
    Write-Host "✅ SSH key added successfully!" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to add SSH key" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

# Test the setup
Write-Host "🧪 Testing SSH connection..." -ForegroundColor Yellow
ssh -o BatchMode=yes -o ConnectTimeout=5 root@165.227.200.202 "echo 'SSH Agent test successful!'"

Write-Host "📋 Current SSH agent status:" -ForegroundColor Yellow
ssh-add -l