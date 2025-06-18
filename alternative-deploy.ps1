# Alternative Deployment Method (if SSH agent still doesn't work)
# This method will ask for passphrase but is more reliable

Write-Host "🚀 Alternative Deployment Method..." -ForegroundColor Cyan
Write-Host "⚠️  You'll need to enter your passphrase for each command" -ForegroundColor Yellow

# Define paths
$sshKey = "C:\Users\lowke\.ssh\id_rsa"
$localPath = "C:\Users\lowke\Projects\CerberusChain"
$remotePath = "root@165.227.200.202:/var/www/cerberuschain.com/"

# Upload files one by one (more reliable)
Write-Host "📤 Uploading index.html..." -ForegroundColor Yellow
scp -i $sshKey "$localPath\index.html" "$remotePath"

Write-Host "📤 Uploading style.css..." -ForegroundColor Yellow  
scp -i $sshKey "$localPath\style.css" "$remotePath"

Write-Host "📤 Uploading animations.css..." -ForegroundColor Yellow
scp -i $sshKey "$localPath\animations.css" "$remotePath"

Write-Host "📤 Uploading script.js..." -ForegroundColor Yellow
scp -i $sshKey "$localPath\script.js" "$remotePath"

# Reload nginx
Write-Host "🔄 Reloading nginx..." -ForegroundColor Yellow
ssh -i $sshKey root@165.227.200.202 "sudo systemctl reload nginx"

Write-Host "✅ Deployment complete!" -ForegroundColor Green
Write-Host "🌐 Visit: https://cerberuschain.com" -ForegroundColor Cyan