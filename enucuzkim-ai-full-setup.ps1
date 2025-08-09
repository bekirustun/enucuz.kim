# ENUCUZ.KIM AI-READY FULL SETUP v2
# Hatasız: JS/TS/JSON config dosyaları doğru sözdizimiyle (tek süslü), UTF-8 ve açıklamalı

$folders = @(
  # apps
  "apps/web/public","apps/web/pages/api","apps/web/components/common","apps/web/components/product-cards","apps/web/components/layout","apps/web/styles","apps/web/utils","apps/web/hooks","apps/web/types","apps/web/middleware",
  "apps/admin/public","apps/admin/pages/auth","apps/admin/pages/products","apps/admin/pages/users","apps/admin/components","apps/admin/styles","apps/admin/utils","apps/admin/hooks",
  # services
  "services/product-service/src/controllers","services/product-service/src/services","services/product-service/src/repositories","services/product-service/src/models","services/product-service/src/config","services/product-service/src/migrations","services/product-service/tests",
  "services/affiliate-service/src/integrations","services/affiliate-service/src/events","services/affiliate-service/tests",
  "services/user-service/src/auth","services/user-service/tests",
  "services/seo-service/src/ai-models","services/seo-service/src/generators","services/seo-service/tests",
  "services/notification-service/src/templates","services/notification-service/src/providers","services/notification-service/tests",
  "services/gateway-service/src","services/gateway-service/tests",
  # infra
  "infra/aws","infra/kubernetes/deployments","infra/kubernetes/services","infra/kubernetes/ingresses","infra/kubernetes/configmaps","infra/kubernetes/secrets","infra/docker","infra/nginx",
  # libs
  "libs/types","libs/utils","libs/hooks","libs/shared-components/Button","libs/shared-components/Input","libs/config",
  # scripts
  "scripts/ci-cd","scripts/db-migrations","scripts/data-import","scripts/deployment","scripts/setup",
  # docs
  "docs/architecture","docs/api","docs/development","docs/operations","docs/meetings",
  # .github
  ".github/workflows",
  # .vscode
  ".vscode"
)

$readmeDesc = @{
  "public" = "Statik dosyalar (görseller, fontlar, favicon vs.)"
  "pages" = "Next.js route/sayfa bileşenleri"
  "components" = "Yeniden kullanılabilir React UI bileşenleri"
  "common" = "Sık kullanılan temel UI bileşenleri"
  "product-cards" = "Ürün kartı şablonları"
  "layout" = "Sayfa/layout yapıları"
  "styles" = "Global CSS/Tailwind dosyaları"
  "utils" = "Yardımcı fonksiyonlar"
  "hooks" = "Özel React hook'ları"
  "types" = "TypeScript tip ve arayüzleri"
  "middleware" = "Orta katmanlar (auth, logging, vs.)"
  "auth" = "Giriş/kayıt işlemleri"
  "products" = "Ürün yönetimi"
  "users" = "Kullanıcı yönetimi"
  "controllers" = "API endpoint mantığı"
  "services-folder" = "Mikroservis ana klasörleri"
  "repositories" = "Veritabanı işlemleri"
  "models" = "Veri şemaları"
  "config-folder" = "Konfigürasyon dosyaları"
  "migrations" = "DB migration scriptleri"
  "integrations" = "Dış servis (mağaza, API) entegrasyonları"
  "events" = "Event/kuyruk mantığı"
  "templates" = "Bildirim şablonları"
  "providers" = "Servis entegratörleri"
  "tests" = "Birim/entegrasyon testleri"
  "deployments" = "Kubernetes deployment manifestleri"
  "services" = "Kubernetes servis manifestleri"
  "ingresses" = "Kubernetes ingress (routing) dosyaları"
  "configmaps" = "Kubernetes configmap dosyaları"
  "secrets" = "Kubernetes secret dosyaları"
  "docker" = "Docker yardımcı dosyaları"
  "nginx" = "Nginx proxy configleri"
  "Button" = "UI Button bileşeni"
  "Input" = "UI Input bileşeni"
  "ci-cd" = "CI/CD scriptleri"
  "db-migrations" = "Ortak DB migration scriptleri"
  "data-import" = "Toplu data işleme scriptleri"
  "deployment" = "Dağıtım yardımcı scriptleri"
  "setup" = "Kurulum scriptleri"
  "architecture" = "Mimari kararlar/diyagramlar"
  "api" = "API dokümantasyonları"
  "development" = "Geliştirme ortamı rehberi"
  "operations" = "Canlı izleme/sorun giderme"
  "meetings" = "Toplantı notları"
  "workflows" = "GitHub Actions"
  "config" = "Global/shared config"
  ".vscode" = "VS Code uzantı/ayarlar"
}

foreach ($f in $folders) {
    if (!(Test-Path $f)) { New-Item -ItemType Directory -Path $f -Force | Out-Null }
    $readmePath = Join-Path $f "README.md"
    $desc = ""
    foreach ($key in $readmeDesc.Keys) { if ($f.ToLower().Contains($key.ToLower())) { $desc = $readmeDesc[$key]; break } }
    if (!(Test-Path $readmePath)) {
        Set-Content $readmePath "# $(Split-Path $f -Leaf)`n$desc`n" -Encoding UTF8
    }
}

# -- KOD & KONFİG DOSYALARI HATASIZ (tek süslü) YAZILIYOR --

Set-Content -Path "apps/web/pages/_app.tsx" -Value @"
import type { AppProps } from 'next/app'
import '../styles/globals.css'
export default function MyApp({ Component, pageProps }: AppProps) {
  return <Component {...pageProps} />
}
"@ -Encoding UTF8

Set-Content -Path "apps/web/pages/_document.tsx" -Value @"
import { Html, Head, Main, NextScript } from 'next/document'
export default function Document() {
  return (
    <Html lang='tr'>
      <Head />
      <body>
        <Main />
        <NextScript />
      </body>
    </Html>
  )
}
"@ -Encoding UTF8

Set-Content -Path "apps/web/pages/index.tsx" -Value @"
export default function Home() {
  return (
    <div className='min-h-screen flex flex-col items-center justify-center bg-blue-50'>
      <h1 className='text-3xl font-bold text-blue-800 mb-6'>
        En Ucuz Kim’e Hoşgeldiniz!
      </h1>
      <p className='text-lg text-gray-700'>
        AI destekli en gelişmiş fiyat karşılaştırma platformu
      </p>
    </div>
  )
}
"@ -Encoding UTF8

Set-Content -Path "apps/web/styles/globals.css" -Value @"
@tailwind base;
@tailwind components;
@tailwind utilities;
body { font-family: 'Inter', sans-serif; }
"@ -Encoding UTF8

Set-Content -Path "apps/web/tailwind.config.js" -Value @"
module.exports = {
  content: [
    './pages/**/*.{js,ts,jsx,tsx}',
    './components/**/*.{js,ts,jsx,tsx}',
    './app/**/*.{js,ts,jsx,tsx}'
  ],
  theme: { extend: {} },
  plugins: [require('@tailwindcss/forms')],
}
"@ -Encoding UTF8

Set-Content -Path "apps/web/postcss.config.js" -Value @"
module.exports = {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
}
"@ -Encoding UTF8

Set-Content -Path "apps/admin/pages/_app.tsx" -Value @"
import type { AppProps } from 'next/app'
import '../styles/globals.css'
export default function MyApp({ Component, pageProps }: AppProps) {
  return <Component {...pageProps} />
}
"@ -Encoding UTF8

Set-Content -Path "apps/admin/pages/dashboard.tsx" -Value @"
export default function Dashboard() {
  return (
    <div className='min-h-screen flex flex-col items-center justify-center bg-green-50'>
      <h1 className='text-2xl font-bold text-green-800 mb-4'>Admin Panel Dashboard</h1>
      <p className='text-gray-700'>Yönetim paneline hoşgeldiniz!</p>
    </div>
  )
}
"@ -Encoding UTF8

Set-Content -Path "apps/admin/styles/globals.css" -Value @"
@tailwind base;
@tailwind components;
@tailwind utilities;
"@ -Encoding UTF8

Set-Content -Path "apps/admin/tailwind.config.js" -Value @"
module.exports = {
  content: [
    './pages/**/*.{js,ts,jsx,tsx}',
    './components/**/*.{js,ts,jsx,tsx}',
    './app/**/*.{js,ts,jsx,tsx}'
  ],
  theme: { extend: {} },
  plugins: [require('@tailwindcss/forms')],
}
"@ -Encoding UTF8

Set-Content -Path "apps/admin/postcss.config.js" -Value @"
module.exports = {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
}
"@ -Encoding UTF8

# VSCode önerileri
Set-Content -Path ".vscode/extensions.json" -Value @"
{
  \"recommendations\": [
    \"dbaeumer.vscode-eslint\",
    \"esbenp.prettier-vscode\",
    \"eamodio.gitlens\"
  ]
}
"@ -Encoding UTF8

Write-Host "`nTüm klasörler, README’ler ve ana kod/config dosyaları düzgün, hatasız ve AI-ready şekilde oluşturuldu! 💙" -ForegroundColor Green