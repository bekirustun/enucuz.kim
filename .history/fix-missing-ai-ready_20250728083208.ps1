# fix-missing-ai-ready.ps1

$apps = @("web", "admin")
$basePath = "$PSScriptRoot\apps"

foreach ($app in $apps) {
    $appPath = Join-Path $basePath $app
    Write-Host "`n--- $app için eksik dosya kontrolü ---" -ForegroundColor Cyan

    # 1. postcss.config.js
    $postcssPath = Join-Path $appPath "postcss.config.js"
    $postcssContent = 'module.exports = { plugins: { tailwindcss: {}, autoprefixer: {}, }, }'
    if (!(Test-Path $postcssPath)) {
        $postcssContent | Set-Content $postcssPath -Encoding UTF8
        Write-Host "✔ postcss.config.js OLUŞTURULDU" -ForegroundColor Green
    } else {
        Write-Host "• postcss.config.js mevcut." -ForegroundColor Yellow
    }

    # 2. tailwind.config.ts
    $tailwindPath = Join-Path $appPath "tailwind.config.ts"
    $tailwindContent = "import type { Config } from 'tailwindcss'`nconst config: Config = {`n  content: [`n    './pages/**/*.{js,ts,jsx,tsx}',`n    './components/**/*.{js,ts,jsx,tsx}',`n    './app/**/*.{js,ts,jsx,tsx}'`n  ],`n  theme: { extend: {} },`n  plugins: [],`n}`nexport default config"
    if (!(Test-Path $tailwindPath)) {
        $tailwindContent | Set-Content $tailwindPath -Encoding UTF8
        Write-Host "✔ tailwind.config.ts OLUŞTURULDU" -ForegroundColor Green
    } else {
        Write-Host "• tailwind.config.ts mevcut." -ForegroundColor Yellow
    }

    # 3. pages/_app.tsx
    $pagesPath = Join-Path $appPath "pages"
    if (!(Test-Path $pagesPath)) { New-Item -ItemType Directory -Path $pagesPath | Out-Null }
    $appTsxPath = Join-Path $pagesPath "_app.tsx"
    $appContent = "import type { AppProps } from 'next/app'`nimport '../styles/globals.css'`nexport default function MyApp({ Component, pageProps }: AppProps) {`n  return <Component {...pageProps} />`n}"
    if (!(Test-Path $appTsxPath)) {
        $appContent | Set-Content $appTsxPath -Encoding UTF8
        Write-Host "✔ pages/_app.tsx OLUŞTURULDU" -ForegroundColor Green
    } else {
        Write-Host "• pages/_app.tsx mevcut." -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "Tüm eksik dosyalar AI standardında otomatik oluşturuldu!" -ForegroundColor Cyan
