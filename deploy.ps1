# PowerShell Deployment Script for CerberusChain
# Save this as deploy.ps1 and run with: .\deploy.ps1

Write-Host "🚀 Deploying CerberusChain website..." -ForegroundColor Cyan

# Define paths
$sshKey = "C:\Users\lowke\.ssh\id_rsa"
$localPath = "C:\Users\lowke\Projects\CerberusChain"
$remotePath = "root@165.227.200.202:/var/www/cerberuschain.com/"

# Upload all files
Write-Host "📤 Uploading HTML file..." -ForegroundColor Yellow
scp -i $sshKey "$localPath\index.html" "$remotePath"

Write-Host "📤 Uploading CSS files..." -ForegroundColor Yellow
scp -i $sshKey "$localPath\style.css" "$remotePath"
scp -i $sshKey "$localPath\animations.css" "$remotePath"

Write-Host "📤 Uploading JavaScript file..." -ForegroundColor Yellow
scp -i $sshKey "$localPath\script.js" "$remotePath"

# Reload nginx
Write-Host "🔄 Reloading nginx..." -ForegroundColor Yellow
ssh -i $sshKey root@165.227.200.202 "sudo systemctl reload nginx"

Write-Host "✅ Deployment complete!" -ForegroundColor Green
Write-Host "🌐 Visit: https://cerberuschain.com" -ForegroundColor Cyan