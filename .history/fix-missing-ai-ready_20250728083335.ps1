# fix-missing-ai-ready.ps1

# WEB için
if (!(Test-Path .\apps\web\postcss.config.js)) {
    Set-Content -Path .\apps\web\postcss.config.js -Value "module.exports = { plugins: { tailwindcss: {}, autoprefixer: {}, }, }" -Encoding UTF8
    Write-Host "✔ web/postcss.config.js OLUŞTURULDU" -ForegroundColor Green
} else { Write-Host "• web/postcss.config.js mevcut." -ForegroundColor Yellow }

if (!(Test-Path .\apps\web\tailwind.config.ts)) {
    Set-Content -Path .\apps\web\tailwind.config.ts -Value "import type { Config } from 'tailwindcss'`nconst config: Config = {`n  content: [`n    './pages/**/*.{js,ts,jsx,tsx}',`n    './components/**/*.{js,ts,jsx,tsx}',`n    './app/**/*.{js,ts,jsx,tsx}'`n  ],`n  theme: { extend: {} },`n  plugins: [],`n}`nexport default config" -Encoding UTF8
    Write-Host "✔ web/tailwind.config.ts OLUŞTURULDU" -ForegroundColor Green
} else { Write-Host "• web/tailwind.config.ts mevcut." -ForegroundColor Yellow }

if (!(Test-Path .\apps\web\pages)) { New-Item -ItemType Directory -Path .\apps\web\pages | Out-Null }
if (!(Test-Path .\apps\web\pages\_app.tsx)) {
    Set-Content -Path .\apps\web\pages\_app.tsx -Value "import type { AppProps } from 'next/app'`nimport '../styles/globals.css'`nexport default function MyApp({ Component, pageProps }: AppProps) {`n  return <Component {...pageProps} />`n}" -Encoding UTF8
    Write-Host "✔ web/pages/_app.tsx OLUŞTURULDU" -ForegroundColor Green
} else { Write-Host "• web/pages/_app.tsx mevcut." -ForegroundColor Yellow }

# ADMIN için
if (!(Test-Path .\apps\admin\tailwind.config.ts)) {
    Set-Content -Path .\apps\admin\tailwind.config.ts -Value "import type { Config } from 'tailwindcss'`nconst config: Config = {`n  content: [`n    './pages/**/*.{js,ts,jsx,tsx}',`n    './components/**/*.{js,ts,jsx,tsx}',`n    './app/**/*.{js,ts,jsx,tsx}'`n  ],`n  theme: { extend: {} },`n  plugins: [],`n}`nexport default config" -Encoding UTF8
    Write-Host "✔ admin/tailwind.config.ts OLUŞTURULDU" -ForegroundColor Green
} else { Write-Host "• admin/tailwind.config.ts mevcut." -ForegroundColor Yellow }

if (!(Test-Path .\apps\admin\pages)) { New-Item -ItemType Directory -Path .\apps\admin\pages | Out-Null }
if (!(Test-Path .\apps\admin\pages\_app.tsx)) {
    Set-Content -Path .\apps\admin\pages\_app.tsx -Value "import type { AppProps } from 'next/app'`nimport '../styles/globals.css'`nexport default function MyApp({ Component, pageProps }: AppProps) {`n  return <Component {...pageProps} />`n}" -Encoding UTF8
    Write-Host "✔ admin/pages/_app.tsx OLUŞTURULDU" -ForegroundColor Green
} else { Write-Host "• admin/pages/_app.tsx mevcut." -ForegroundColor Yellow }

Write-Host ""
Write-Host "Tüm eksik dosyalar AI standardında otomatik oluşturuldu!" -ForegroundColor Cyan
