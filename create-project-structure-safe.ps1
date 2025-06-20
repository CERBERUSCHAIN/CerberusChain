# Cerberus Chain: Hydra - SAFE Project Structure Generator
# This script will NOT overwrite existing files
# Run this script from: C:\Users\lowke\Projects\Cerberus-Chain-Hydra

Write-Host "🐺 Creating Cerberus Chain: Hydra Project Structure (SAFE MODE)..." -ForegroundColor Cyan
Write-Host "📁 Base Directory: $PWD" -ForegroundColor Yellow
Write-Host "⚠️  This script will NOT overwrite existing files" -ForegroundColor Green

# Function to safely create files (only if they don't exist)
function New-SafeFile {
    param(
        [string]$FilePath,
        [string[]]$Content
    )
    
    if (Test-Path $FilePath) {
        Write-Host "  [SKIP] Already exists: $FilePath" -ForegroundColor Yellow
    } else {
        $Content | Out-File -FilePath $FilePath -Encoding UTF8
        Write-Host "  [NEW] Created: $FilePath" -ForegroundColor Green
    }
}

# Function to safely create directories
function New-SafeDirectory {
    param([string]$Path)
    
    if (Test-Path $Path) {
        Write-Host "  [SKIP] Directory exists: $Path" -ForegroundColor Yellow
    } else {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
        Write-Host "  [NEW] Created directory: $Path" -ForegroundColor Green
    }
}

# Ensure we're in the correct directory
$projectRoot = "C:\Users\lowke\Projects\Cerberus-Chain-Hydra"

if (-not (Test-Path $projectRoot)) {
    Write-Host "📁 Creating project root directory: $projectRoot" -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $projectRoot -Force | Out-Null
}

if ($PWD.Path -ne $projectRoot) {
    Write-Host "⚠️  Changing to project directory: $projectRoot" -ForegroundColor Yellow
    Set-Location $projectRoot
}

# Create main project structure
$folders = @(
    # Root level
    ".github/workflows",
    "docs",
    "scripts",
    
    # Backend (Rust)
    "backend/src/auth",
    "backend/src/api",
    "backend/src/bots",
    "backend/src/wallet",
    "backend/src/database",
    "backend/src/helius",
    "backend/src/notifications",
    "backend/src/utils",
    "backend/src/config",
    
    # Frontend
    "frontend/src",
    "frontend/public"
)

Write-Host "📂 Creating folder structure..." -ForegroundColor Cyan
foreach ($folder in $folders) {
    New-SafeDirectory -Path $folder
}

Write-Host "📄 Creating missing configuration files..." -ForegroundColor Cyan

# Only create files that are missing for the frontend to work

# Frontend vite.config.ts
$viteConfigContent = @"
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  server: {
    port: 5173,
    host: true
  }
})
"@

New-SafeFile -FilePath "frontend/vite.config.ts" -Content $viteConfigContent

# Frontend tsconfig.json
$tsconfigContent = @"
{
  "compilerOptions": {
    "target": "ES2020",
    "useDefineForClassFields": true,
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "skipLibCheck": true,
    "esModuleInterop": true,
    "allowSyntheticDefaultImports": true,

    "moduleResolution": "bundler",
    "allowImportingTsExtensions": false,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "jsx": "react-jsx",

    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noFallthroughCasesInSwitch": true
  },
  "include": ["src"],
  "references": [{ "path": "./tsconfig.node.json" }]
}
"@

New-SafeFile -FilePath "frontend/tsconfig.json" -Content $tsconfigContent

# Frontend tsconfig.node.json
$tsconfigNodeContent = @"
{
  "compilerOptions": {
    "composite": true,
    "skipLibCheck": true,
    "module": "ESNext",
    "moduleResolution": "bundler",
    "allowSyntheticDefaultImports": true
  },
  "include": ["vite.config.ts"]
}
"@

New-SafeFile -FilePath "frontend/tsconfig.node.json" -Content $tsconfigNodeContent

# Frontend index.html
$indexHtmlContent = @"
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <link rel="icon" type="image/svg+xml" href="/vite.svg" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Cerberus Chain: Hydra</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.tsx"></script>
  </body>
</html>
"@

New-SafeFile -FilePath "frontend/index.html" -Content $indexHtmlContent

# Backend module files (only if missing)
$backendModules = @{
    "backend/src/auth/mod.rs" = "// Authentication module"
    "backend/src/api/mod.rs" = "// API routes module"
    "backend/src/bots/mod.rs" = "// Trading bots module"
    "backend/src/wallet/mod.rs" = "// Wallet management module"
    "backend/src/database/mod.rs" = "// Database operations module"
    "backend/src/helius/mod.rs" = "// Helius integration module"
    "backend/src/notifications/mod.rs" = "// Notifications module"
    "backend/src/utils/mod.rs" = "// Utility functions module"
    "backend/src/config/mod.rs" = "// Configuration module"
}

Write-Host "🦀 Creating backend module files..." -ForegroundColor Cyan
foreach ($module in $backendModules.GetEnumerator()) {
    New-SafeFile -FilePath $module.Key -Content $module.Value
}

# Environment file (only if missing)
if (-not (Test-Path ".env")) {
    Write-Host "📄 Creating .env file from template..." -ForegroundColor Yellow
    if (Test-Path ".env.example") {
        Copy-Item ".env.example" ".env"
        Write-Host "  [NEW] Created .env from .env.example" -ForegroundColor Green
    } else {
        Write-Host "  [SKIP] .env.example not found, skipping .env creation" -ForegroundColor Yellow
    }
} else {
    Write-Host "  [SKIP] .env file already exists" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "🎉 Safe project structure creation completed!" -ForegroundColor Green
Write-Host ""
Write-Host "📊 Summary:" -ForegroundColor Yellow
Write-Host "  ✅ Existing files were NOT modified" -ForegroundColor Green
Write-Host "  ✅ Only missing files were created" -ForegroundColor Green
Write-Host "  ✅ Your current work is preserved" -ForegroundColor Green
Write-Host ""
Write-Host "🎯 Next Steps:" -ForegroundColor Cyan
Write-Host "  1. Your TypeScript errors should now be fixed!" -ForegroundColor White
Write-Host "  2. Try running: cd frontend && npm run dev" -ForegroundColor White
Write-Host "  3. Check if the frontend loads without errors" -ForegroundColor White
Write-Host ""
Write-Host "🚀 Ready to continue development!" -ForegroundColor Magenta