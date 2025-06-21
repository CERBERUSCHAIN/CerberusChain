# Fix Network Issues - Run as Administrator
# This fixes Windows Firewall blocking Supabase

Write-Host "🔧 Fixing Network Issues" -ForegroundColor Cyan
Write-Host "========================" -ForegroundColor White
Write-Host ""

# Check admin rights
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

if (-not $isAdmin) {
    Write-Host "❌ This script needs Administrator rights" -ForegroundColor Red
    Write-Host "💡 Right-click PowerShell → 'Run as Administrator'" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Running as Administrator" -ForegroundColor Green
Write-Host ""

# Add firewall rules
Write-Host "🛡️ Adding firewall rules..." -ForegroundColor Yellow
netsh advfirewall firewall add rule name="Rust PostgreSQL" dir=out action=allow protocol=TCP remoteport=5432,6543 | Out-Null
Write-Host "✅ Firewall rules added" -ForegroundColor Green

# Change DNS
Write-Host "🌐 Changing DNS to Google..." -ForegroundColor Yellow
$adapter = Get-NetAdapter | Where-Object {$_.Status -eq "Up" -and $_.Virtual -eq $false} | Select-Object -First 1
if ($adapter) {
    Set-DnsClientServerAddress -InterfaceIndex $adapter.InterfaceIndex -ServerAddresses "8.8.8.8","8.8.4.4"
    Write-Host "✅ DNS changed to Google DNS" -ForegroundColor Green
}

# Reset network
Write-Host "🔄 Resetting network..." -ForegroundColor Yellow
ipconfig /flushdns | Out-Null
netsh winsock reset | Out-Null
Write-Host "✅ Network reset" -ForegroundColor Green

Write-Host ""
Write-Host "🎉 Network fixes applied!" -ForegroundColor Green
Write-Host "🔄 Restart your computer, then test: cd backend && cargo run" -ForegroundColor Cyan