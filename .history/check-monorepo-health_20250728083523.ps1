# check-monorepo-health.ps1
$apps = @("web", "admin")
$basePath = "$PSScriptRoot\apps"
$checks = @(
    "package.json",
    "postcss.config.js",
    "tailwind.config.ts",
    "styles\globals.css",
    "pages\_app.tsx"
)

foreach ($app in $apps) {
    $appPath = Join-Path $basePath $app
    Write-Host "`n------ $app APP SAGLIK TARAMASI ------`n" -ForegroundColor Cyan

    foreach ($check in $checks) {
        $targetPath = Join-Path $appPath $check
        if (Test-Path $targetPath) {
            Write-Host "✅ $check mevcut." -ForegroundColor Green
        } else {
            Write-Host "❌ $check EKSİK!" -ForegroundColor Red
        }
    }

    # Ekstra: _document.tsx (isteğe bağlı)
    $documentPath = Join-Path $appPath "pages\_document.tsx"
    if (Test-Path $documentPath) {
        Write-Host "✅ pages/_document.tsx mevcut." -ForegroundColor Green
    } else {
        Write-Host "⚠️  pages/_document.tsx isteğe bağlı, yok." -ForegroundColor Yellow
    }
}

Write-Host "`nTarama tamamlandı. Eksik dosya varsa yukarıda kırmızı olarak görürsün." -ForegroundColor Cyan
# fix-missing-ai-ready.ps1

# WEB için
if (!(Test-Path .\apps\web\postcss.config.js)) {
    Set-Content -Path .\apps\web\postcss.config.js -Value "module.exports = { plugins: { tailwindcss: {}, autoprefixer: {}, }, }" -Encoding UTF8
    Write-Host "web/postcss.config.js created." -ForegroundColor Green
} else { Write-Host "web/postcss.config.js already exists." -ForegroundColor Yellow }

if (!(Test-Path .\apps\web\tailwind.config.ts)) {
    Set-Content -Path .\apps\web\tailwind.config.ts -Value "import type { Config } from 'tailwindcss'`nconst config: Config = {`n  content: [`n    './pages/**/*.{js,ts,jsx,tsx}',`n    './components/**/*.{js,ts,jsx,tsx}',`n    './app/**/*.{js,ts,jsx,tsx}'`n  ],`n  theme: { extend: {} },`n  plugins: [],`n}`nexport default config" -Encoding UTF8
    Write-Host "web/tailwind.config.ts created." -ForegroundColor Green
} else { Write-Host "web/tailwind.config.ts already exists." -ForegroundColor Yellow }

if (!(Test-Path .\apps\web\pages)) { New-Item -ItemType Directory -Path .\apps\web\pages | Out-Null }
if (!(Test-Path .\apps\web\pages\_app.tsx)) {
    Set-Content -Path .\apps\web\pages\_app.tsx -Value "import type { AppProps } from 'next/app'`nimport '../styles/globals.css'`nexport default function MyApp({ Component, pageProps }: AppProps) {`n  return <Component {...pageProps} />`n}" -Encoding UTF8
    Write-Host "web/pages/_app.tsx created." -ForegroundColor Green
} else { Write-Host "web/pages/_app.tsx already exists." -ForegroundColor Yellow }

# ADMIN için
if (!(Test-Path .\apps\admin\tailwind.config.ts)) {
    Set-Content -Path .\apps\admin\tailwind.config.ts -Value "import type { Config } from 'tailwindcss'`nconst config: Config = {`n  content: [`n    './pages/**/*.{js,ts,jsx,tsx}',`n    './components/**/*.{js,ts,jsx,tsx}',`n    './app/**/*.{js,ts,jsx,tsx}'`n  ],`n  theme: { extend: {} },`n  plugins: [],`n}`nexport default config" -Encoding UTF8
    Write-Host "admin/tailwind.config.ts created." -ForegroundColor Green
} else { Write-Host "admin/tailwind.config.ts already exists." -ForegroundColor Yellow }

if (!(Test-Path .\apps\admin\pages)) { New-Item -ItemType Directory -Path .\apps\admin\pages | Out-Null }
if (!(Test-Path .\apps\admin\pages\_app.tsx)) {
    Set-Content -Path .\apps\admin\pages\_app.tsx -Value "import type { AppProps } from 'next/app'`nimport '../styles/globals.css'`nexport default function MyApp({ Component, pageProps }: AppProps) {`n  return <Component {...pageProps} />`n}" -Encoding UTF8
    Write-Host "admin/pages/_app.tsx created." -ForegroundColor Green
} else { Write-Host "admin/pages/_app.tsx already exists." -ForegroundColor Yellow }

Write-Host ""
Write-Host "All missing files are created successfully." -ForegroundColor Cyan
