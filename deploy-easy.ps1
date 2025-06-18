# Easy Deployment Script (works after SSH agent is set up)
# No more passphrase prompts!

Write-Host "🚀 Deploying CerberusChain website..." -ForegroundColor Cyan

# Define paths
$localPath = "C:\Users\lowke\Projects\CerberusChain"
$remotePath = "root@165.227.200.202:/var/www/cerberuschain.com/"

# Upload all files (NO -i flag needed when using SSH agent)
Write-Host "📤 Uploading all files..." -ForegroundColor Yellow
scp "$localPath\index.html" "$localPath\style.css" "$localPath\animations.css" "$localPath\script.js" $remotePath

# Reload nginx
Write-Host "🔄 Reloading nginx..." -ForegroundColor Yellow
ssh root@165.227.200.202 "sudo systemctl reload nginx"

Write-Host "✅ Deployment complete!" -ForegroundColor Green
Write-Host "🌐 Visit: https://cerberuschain.com" -ForegroundColor Cyan