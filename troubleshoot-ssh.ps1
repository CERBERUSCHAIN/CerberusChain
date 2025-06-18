# SSH Troubleshooting Script
# Run this to diagnose SSH issues

Write-Host "🔍 SSH Troubleshooting..." -ForegroundColor Cyan

Write-Host "📋 System Information:" -ForegroundColor Yellow
Write-Host "PowerShell Version: $($PSVersionTable.PSVersion)" -ForegroundColor Gray
Write-Host "Windows Version: $([System.Environment]::OSVersion.Version)" -ForegroundColor Gray

Write-Host "📋 SSH Configuration:" -ForegroundColor Yellow
Write-Host "SSH Key Path: C:\Users\lowke\.ssh\id_rsa" -ForegroundColor Gray
Write-Host "SSH Key Exists: $(Test-Path 'C:\Users\lowke\.ssh\id_rsa')" -ForegroundColor Gray

Write-Host "📋 SSH Agent Status:" -ForegroundColor Yellow
try {
    $sshAgentService = Get-Service ssh-agent -ErrorAction Stop
    Write-Host "SSH Agent Service Status: $($sshAgentService.Status)" -ForegroundColor Gray
} catch {
    Write-Host "SSH Agent Service: Not Found" -ForegroundColor Red
}

Write-Host "📋 OpenSSH Installation:" -ForegroundColor Yellow
$openssh = Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH*'
$openssh | ForEach-Object {
    Write-Host "$($_.Name): $($_.State)" -ForegroundColor Gray
}

Write-Host "📋 SSH Commands Available:" -ForegroundColor Yellow
$sshCommands = @('ssh', 'scp', 'ssh-add', 'ssh-keygen')
foreach ($cmd in $sshCommands) {
    $path = Get-Command $cmd -ErrorAction SilentlyContinue
    if ($path) {
        Write-Host "$cmd: $($path.Source)" -ForegroundColor Gray
    } else {
        Write-Host "$cmd: Not Found" -ForegroundColor Red
    }
}

Write-Host "📋 Environment Variables:" -ForegroundColor Yellow
Write-Host "SSH_AUTH_SOCK: $($env:SSH_AUTH_SOCK)" -ForegroundColor Gray
Write-Host "SSH_AGENT_PID: $($env:SSH_AGENT_PID)" -ForegroundColor Gray

Write-Host "🧪 Testing SSH Key:" -ForegroundColor Yellow
try {
    ssh-keygen -l -f "C:\Users\lowke\.ssh\id_rsa.pub"
} catch {
    Write-Host "❌ Could not read SSH key" -ForegroundColor Red
}