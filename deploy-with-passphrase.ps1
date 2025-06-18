# RELIABLE DEPLOYMENT - Works even if SSH agent fails
# You'll enter passphrase a few times, but it WILL work

Write-Host "🚀 Deploying CerberusChain (Reliable Method)..." -ForegroundColor Cyan
Write-Host "⚠️  You'll need to enter your SSH passphrase for each command" -ForegroundColor Yellow

$sshKey = "C:\Users\lowke\.ssh\id_rsa"
$localPath = "C:\Users\lowke\Projects\CerberusChain"

# Upload files one at a time (most reliable)
Write-Host "📤 Uploading index.html..." -ForegroundColor Yellow
scp -i $sshKey "$localPath\index.html" root@165.227.200.202:/var/www/cerberuschain.com/

Write-Host "📤 Uploading style.css..." -ForegroundColor Yellow  
scp -i $sshKey "$localPath\style.css" root@165.227.200.202:/var/www/cerberuschain.com/

Write-Host "📤 Uploading animations.css..." -ForegroundColor Yellow
scp -i $sshKey "$localPath\animations.css" root@165.227.200.202:/var/www/cerberuschain.com/

Write-Host "📤 Uploading script.js..." -ForegroundColor Yellow
scp -i $sshKey "$localPath\script.js" root@165.227.200.202:/var/www/cerberuschain.com/

Write-Host "🔄 Reloading nginx..." -ForegroundColor Yellow
ssh -i $sshKey root@165.227.200.202 "sudo systemctl reload nginx"

Write-Host "✅ Deployment complete!" -ForegroundColor Green
Write-Host "🌐 Visit: https://cerberuschain.com" -ForegroundColor Cyan