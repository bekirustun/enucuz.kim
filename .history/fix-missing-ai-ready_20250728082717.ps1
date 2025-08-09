# fix-missing-ai-ready.ps1
# Eksik Next.js, Tailwind, PostCSS dosyalarını otomatik oluşturur

$apps = @("web", "admin")
$basePath = "$PSScriptRoot\apps"

# Dosya şablonları
$templates = @{
    "postcss.config.js" = @"
module.exports = {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
}
"@
    "tailwind.config.ts" = @"
import type { Config } from 'tailwindcss'
const config: Config = {
  content: [
    './pages/**/*.{js,ts,jsx,tsx}',
    './components/**/*.{js,ts,jsx,tsx}',
    './app/**/*.{js,ts,jsx,tsx}'
  ],
  theme: { extend: {} },
  plugins: [],
}
export default config
"@
    "_app.tsx" = @"
import type { AppProps } from 'next/app'
import '../styles/globals.css'
export default function MyApp({ Component, pageProps }: AppProps) {
  return <Component {...pageProps} />
}
"@
}

foreach ($app in $apps) {
    $appPath = Join-Path $basePath $app
    Write-Host "`n--- $app için eksik dosya kontrolü ---" -ForegroundColor Cyan

    # 1. postcss.config.js
    $postcssPath = Join-Path $appPath "postcss.config.js"
    if (!(Test-Path $postcssPath)) {
        $templates["postcss.config.js"] | Set-Content $postcssPath -Encoding UTF8
        Write-Host "✔ postcss.config.js OLUŞTURULDU" -ForegroundColor Green
    } else {
        Write-Host "• postcss.config.js mevcut." -ForegroundColor Yellow
    }

    # 2. tailwind.config.ts
    $tailwindPath = Join-Path $appPath "tailwind.config.ts"
    if (!(Test-Path $tailwindPath)) {
        $templates["tailwind.config.ts"] | Set-Content $tailwindPath -Encoding UTF8
        Write-Host "✔ tailwind.config.ts OLUŞTURULDU" -ForegroundColor Green
    } else {
        Write-Host "• tailwind.config.ts mevcut." -ForegroundColor Yellow
    }

    # 3. pages/_app.tsx
    $pagesPath = Join-Path $appPath "pages"
    if (!(Test-Path $pagesPath)) { New-Item -ItemType Directory -Path $pagesPath | Out-Null }
    $appTsxPath = Join-Path $pagesPath "_app.tsx"
    if (!(Test-Path $appTsxPath)) {
        $templates["_app.tsx"] | Set-Content $appTsxPath -Encoding UTF8
        Write-Host "✔ pages/_app.tsx OLUŞTURULDU" -ForegroundColor Green
    } else {
        Write-Host "• pages/_app.tsx mevcut." -ForegroundColor Yellow
    }
}

Write-Host "`nTüm eksik dosyalar AI standardında otomatik oluşturuldu!" -ForegroundColor Cyan
