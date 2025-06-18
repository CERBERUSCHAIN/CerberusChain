# SSH Agent Setup Script for Windows PowerShell
# Run this ONCE to set up SSH agent, then your passphrase will be cached

Write-Host "🔐 Setting up SSH Agent..." -ForegroundColor Cyan

# Start SSH Agent
Start-Service ssh-agent
Set-Service -Name ssh-agent -StartupType Automatic

Write-Host "✅ SSH Agent started" -ForegroundColor Green

# Add your SSH key to the agent (you'll need to enter passphrase ONE TIME)
Write-Host "🔑 Adding SSH key to agent..." -ForegroundColor Yellow
Write-Host "You'll be prompted for your passphrase ONE TIME only..." -ForegroundColor Yellow

ssh-add C:\Users\lowke\.ssh\id_rsa

Write-Host "✅ SSH key added to agent!" -ForegroundColor Green
Write-Host "🎉 You won't need to enter your passphrase again until you restart your computer!" -ForegroundColor Cyan
Write-Host "" 
Write-Host "💡 To make this permanent across reboots, add this to your PowerShell profile:" -ForegroundColor Yellow
Write-Host "   ssh-add C:\Users\lowke\.ssh\id_rsa" -ForegroundColor Gray