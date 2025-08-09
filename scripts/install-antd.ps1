Param(
  [string]$WebPkg   = "enucuzkim-web",
  [string]$AdminPkg = "enucuzkim-admin",
  [string]$RepoRoot = (Resolve-Path ".").Path
)

# === Helpers ===
function Assert-Command {
  param([string]$Name)
  if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
    Write-Host "Komut bulunamadı: $Name. Lütfen kurun ve tekrar deneyin." -ForegroundColor Red
    exit 1
  }
}

function Add-Import-IfMissing {
  param(
    [string]$FilePath,
    [string]$ImportLine
  )
  if (-not (Test-Path "$FilePath")) { return }
  $content = Get-Content -Raw -Path "$FilePath"
  if ($content -notmatch [Regex]::Escape($ImportLine)) {
    # Import'u en üste ekle
    $new = "$ImportLine`r`n$content"
    Set-Content -Path "$FilePath" -Value $new -Encoding UTF8
    Write-Host "Import eklendi: $ImportLine -> $FilePath" -ForegroundColor Green
  }
}

function Ensure-File {
  param(
    [string]$Path,
    [string]$Content
  )
  $dir = Split-Path -Parent "$Path"
  if (-not (Test-Path "$dir")) { New-Item -ItemType Directory -Force -Path "$dir" | Out-Null }
  if (-not (Test-Path "$Path")) {
    Set-Content -Path "$Path" -Value $Content -Encoding UTF8
    Write-Host "Dosya oluşturuldu: $Path" -ForegroundColor Green
  } else {
    Write-Host "Dosya zaten var, atlandı: $Path" -ForegroundColor Yellow
  }
}

function Inject-AntdProvider-Into-Layout {
  param([string]$LayoutPath)

  if (-not (Test-Path "$LayoutPath")) { return }

  $content = Get-Content -Raw -Path "$LayoutPath"
  $original = $content

  # 1) reset.css import
  if ($content -notmatch "antd/dist/reset.css") {
    $content = "import 'antd/dist/reset.css';`r`n$content"
  }

  # 2) AntdProvider import
  if ($content -notmatch "from './AntdProvider'") {
    $content = $content -replace "^(.*?import[^\n]*\n)*", "`$0import AntdProvider from './AntdProvider';`r`n"
  }

  # 3) <AntdProvider> sarmalama
  if ($content -notmatch "<AntdProvider>") {
    $content = $content -replace "(<body[^>]*>\s*)", "`$1<AntdProvider>"
    $content = $content -replace "(\s*</body>)", "</AntdProvider>`$1"
  }

  if ($content -ne $original) {
    Copy-Item -Path "$LayoutPath" -Destination "$LayoutPath.bak" -Force
    Set-Content -Path "$LayoutPath" -Value $content -Encoding UTF8
    Write-Host "layout.tsx güncellendi (yedek: layout.tsx.bak)" -ForegroundColor Green
  } else {
    Write-Host "layout.tsx zaten uygun görünüyor, değişiklik yapılmadı." -ForegroundColor Yellow
  }
}

# === Kontroller ===
Assert-Command -Name "pnpm"

Write-Host "==== Ant Design Otomatik Kurulum Başlıyor ====" -ForegroundColor Cyan
Write-Host "Repo kökü: $RepoRoot" -ForegroundColor DarkCyan
Write-Host "Web paketi: $WebPkg  | Admin paketi: $AdminPkg" -ForegroundColor DarkCyan

# === 1) Bağımlılıkların kurulumu ===
$deps = @("antd","@ant-design/icons","classnames","dayjs","@ant-design/cssinjs")

Write-Host "`n[1/4] Paketler kuruluyor (web)..." -ForegroundColor Cyan
pnpm --filter "$WebPkg" add $deps
if ($LASTEXITCODE -ne 0) { Write-Host "Paket kurulumu (web) başarısız." -ForegroundColor Red; exit 1 }

Write-Host "[2/4] Paketler kuruluyor (admin)..." -ForegroundColor Cyan
pnpm --filter "$AdminPkg" add $deps
if ($LASTEXITCODE -ne 0) { Write-Host "Paket kurulumu (admin) başarısız." -ForegroundColor Red; exit 1 }

# === 2) App Router (apps/web) dosyaları ===
$webAppDir   = Join-Path "$RepoRoot" "apps\web\app"
$providerTsx = Join-Path "$webAppDir" "AntdProvider.tsx"
$layoutTsx   = Join-Path "$webAppDir" "layout.tsx"

$providerContent = @'
\'use client\';

import React, { useMemo } from "react";
import { StyleProvider, createCache, extractStyle } from "@ant-design/cssinjs";
import { useServerInsertedHTML } from "next/navigation";

export default function AntdProvider({ children }: { children: React.ReactNode }) {
  const cache = useMemo(() => createCache(), []);
  useServerInsertedHTML(() => (
    <style id="antd" dangerouslySetInnerHTML={{ __html: extractStyle(cache, true) }} />
  ));
  return <StyleProvider cache={cache}>{children}</StyleProvider>;
}
'@

Ensure-File -Path "$providerTsx" -Content $providerContent

if (Test-Path "$layoutTsx") {
  Inject-AntdProvider-Into-Layout -LayoutPath "$layoutTsx"
} else {
  # Minimal layout oluştur
  $minimalLayout = @'
import "antd/dist/reset.css";
import AntdProvider from "./AntdProvider";

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="tr">
      <body>
        <AntdProvider>{children}</AntdProvider>
      </body>
    </html>
  );
}
'@
  Ensure-File -Path "$layoutTsx" -Content $minimalLayout
}

# Demo sayfası (apps/web/app/antd-demo/page.tsx)
$webDemoDir  = Join-Path "$webAppDir" "antd-demo"
$webDemoPage = Join-Path "$webDemoDir" "page.tsx"
$webDemoContent = @'
"use client";
import { Button, DatePicker, ConfigProvider } from "antd";
import trTR from "antd/locale/tr_TR";
import dayjs from "dayjs";
import "dayjs/locale/tr";
dayjs.locale("tr");

export default function AntdDemoPage() {
  return (
    <ConfigProvider locale={trTR}>
      <div style={{ padding: 24 }}>
        <Button type="primary">Merhaba Antd</Button>
        <span style={{ marginLeft: 12 }} />
        <DatePicker />
      </div>
    </ConfigProvider>
  );
}
'@
Ensure-File -Path "$webDemoPage" -Content $webDemoContent

# === 3) Pages Router (apps/admin) dosyaları ===
$adminPagesDir = Join-Path "$RepoRoot" "apps\admin\pages"
$adminApp      = Join-Path "$adminPagesDir" "_app.tsx"
$adminDoc      = Join-Path "$adminPagesDir" "_document.tsx"
$adminDemo     = Join-Path "$adminPagesDir" "antd-demo.tsx"

$adminAppContent = @'
import type { AppProps } from "next/app";
import "antd/dist/reset.css";

export default function MyApp({ Component, pageProps }: AppProps) {
  return <Component {...pageProps} />;
}
'@
Ensure-File -Path "$adminApp" -Content $adminAppContent

$adminDocContent = @'
import Document, { Html, Head, Main, NextScript, DocumentContext } from "next/document";
import { createCache, extractStyle, StyleProvider } from "@ant-design/cssinjs";

export default class MyDocument extends Document {
  static async getInitialProps(ctx: DocumentContext) {
    const cache = createCache();
    const originalRenderPage = ctx.renderPage;
    let css = "";

    ctx.renderPage = () =>
      originalRenderPage({
        enhanceApp: (App: any) => (props) => {
          const res = (
            <StyleProvider cache={cache}>
              <App {...props} />
            </StyleProvider>
          );
          css = extractStyle(cache, true);
          return res;
        }
      });

    const initialProps = await Document.getInitialProps(ctx);
    return {
      ...initialProps,
      styles: (
        <>
          {initialProps.styles}
          <style id="antd-cssinjs" dangerouslySetInnerHTML={{ __html: css }} />
        </>
      )
    };
  }

  render() {
    return (
      <Html lang="tr">
        <Head />
        <body>
          <Main />
          <NextScript />
        </body>
      </Html>
    );
  }
}
'@
Ensure-File -Path "$adminDoc" -Content $adminDocContent

$adminDemoContent = @'
import { Button, DatePicker, ConfigProvider } from "antd";
import trTR from "antd/locale/tr_TR";
import dayjs from "dayjs";
import "dayjs/locale/tr";
dayjs.locale("tr");

export default function AntdDemo() {
  return (
    <ConfigProvider locale={trTR}>
      <div style={{ padding: 24 }}>
        <Button type="primary">Merhaba Antd</Button>
        <span style={{ marginLeft: 12 }} />
        <DatePicker />
      </div>
    </ConfigProvider>
  );
}
'@
Ensure-File -Path "$adminDemo" -Content $adminDemoContent

# _app.tsx içine reset import u zaten yazdık; var olan dosyada yoksa ekle
Add-Import-IfMissing -FilePath "$adminApp" -ImportLine "import 'antd/dist/reset.css';"

# === 4) Bitti / yönergeler ===
Write-Host "`n==== Kurulum tamam ====" -ForegroundColor Green
Write-Host "Test için:" -ForegroundColor Cyan
Write-Host "  - Web (App Router):    pnpm --filter `"$WebPkg`" dev  →  /antd-demo" -ForegroundColor Gray
Write-Host "  - Admin (Pages):       pnpm --filter `"$AdminPkg`" dev →  /antd-demo" -ForegroundColor Gray
