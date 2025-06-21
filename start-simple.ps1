# Start Cerberus Chain: Hydra (Simple Version)
# No Docker, no Supabase, just works!

Write-Host "🐺 Starting Cerberus Chain: Hydra (Simple Version)" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor White
Write-Host ""

Write-Host "📋 Simple local setup:" -ForegroundColor Green
Write-Host "   ✅ SQLite database (no server required)" -ForegroundColor Gray
Write-Host "   ✅ No Docker needed" -ForegroundColor Gray
Write-Host "   ✅ No network dependencies" -ForegroundColor Gray
Write-Host ""

# Start backend
Write-Host "🦀 Starting backend..." -ForegroundColor Yellow
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd backend; Write-Host 'Cerberus Chain Backend (SQLite)' -ForegroundColor Cyan; cargo run"

# Wait a moment
Start-Sleep -Seconds 2

# Start frontend
Write-Host "⚛️ Starting frontend..." -ForegroundColor Yellow
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd frontend; Write-Host 'Cerberus Chain Frontend' -ForegroundColor Cyan; npm run dev"

Write-Host ""
Write-Host "🎉 Simple setup complete!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Services:" -ForegroundColor Cyan
Write-Host "   🗄️ Database:  SQLite file (cerberus_hydra.db)" -ForegroundColor White
Write-Host "   🦀 Backend:   http://localhost:8080" -ForegroundColor White
Write-Host "   ⚛️ Frontend:  http://localhost:3000" -ForegroundColor White
Write-Host ""
Write-Host "🌐 Open http://localhost:3000 in your browser" -ForegroundColor Green
Write-Host ""
Write-Host "✨ This version has NO network dependencies!" -ForegroundColor Magenta