# fix-users-name-null.ps1
# users.name kolonunu güvenli şekilde oluşturur/doldurur ve NOT NULL yapar.

param(
  [string]$EnvFile = "D:\U\S\enucuz.kim\services\user-service\.env"
)

function Get-PsqlPath {
  $cmd = (Get-Command psql.exe -ErrorAction SilentlyContinue)
  if($cmd){ return $cmd.Source }

  $paths = @(
    "C:\Program Files\PostgreSQL\17\bin\psql.exe",
    "C:\Program Files\PostgreSQL\16\bin\psql.exe",
    "C:\Program Files\PostgreSQL\15\bin\psql.exe"
  )
  $found = $paths | Where-Object { Test-Path $_ } | Select-Object -First 1
  if($found){ return $found }

  # Servisten bin yolunu bul
  $svc = Get-Service | Where-Object { $_.Name -match "postgres" } | Select-Object -First 1
  if($svc){
    $reg = "HKLM:\SYSTEM\CurrentControlSet\Services\{0}" -f $svc.Name
    $img = (Get-ItemProperty $reg -ErrorAction SilentlyContinue).ImagePath
    if($img){
      $bin = [System.IO.Path]::GetDirectoryName( ($img -replace '"','').Split(' ')[0] )
      $psql = Join-Path $bin "psql.exe"
      if(Test-Path $psql){ return $psql }
    }
  }

  throw "psql.exe bulunamadı. PostgreSQL Client kurulu mu? (Windows için: resmi installer veya PATH'e ekleyin)"
}

function Read-DotEnv($path){
  if(-not (Test-Path $path)){ throw ".env bulunamadı: $path" }
  $map = @{}
  Get-Content $path | ForEach-Object {
    if($_ -match '^\s*#'){ return }
    if($_ -match '^\s*$'){ return }
    $k,$v = $_ -split '=',2
    $map[$k.Trim()] = $v.Trim()
  }
  return $map
}

Write-Host "=== users.name NOT NULL düzeltmesi ===" -ForegroundColor Cyan
$envmap = Read-DotEnv $EnvFile

$DB_HOST = $envmap["DB_HOST"]; if(-not $DB_HOST){ $DB_HOST="localhost" }
$DB_PORT = $envmap["DB_PORT"]; if(-not $DB_PORT){ $DB_PORT="5432" }
$DB_USER = $envmap["DB_USER"]; if(-not $DB_USER){ $DB_USER="postgres" }
$DB_PASS = $envmap["DB_PASS"]; if(-not $DB_PASS){ throw "DB_PASS .env içinde bulunamadı" }
$DB_NAME = $envmap["DB_NAME"]; if(-not $DB_NAME){ throw "DB_NAME .env içinde bulunamadı" }

$psql = Get-PsqlPath
Write-Host ("psql -> {0}" -f $psql)

$env:PGPASSWORD = $DB_PASS

# Strateji:
# 1) name kolonu yoksa DEFAULT ile ekle (Unknown)
# 2) mevcut NULL kayıtları doldur
# 3) NOT NULL yap
# 4) DEFAULT'ı kaldır (opsiyonel)
$steps = @(
  'ALTER TABLE public.users ADD COLUMN IF NOT EXISTS name varchar(120) DEFAULT ''Unknown'';',
  'UPDATE public.users SET name = ''Unknown'' WHERE name IS NULL;',
  'ALTER TABLE public.users ALTER COLUMN name SET NOT NULL;',
  'ALTER TABLE public.users ALTER COLUMN name DROP DEFAULT;'
)

foreach($sql in $steps){
  Write-Host "SQL: $sql" -ForegroundColor Yellow
  & $psql -U $DB_USER -h $DB_HOST -p $DB_PORT -d $DB_NAME -c "$sql"
  if($LASTEXITCODE -ne 0){
    throw "Komut başarısız: $sql (exit $LASTEXITCODE)"
  }
}

Write-Host "✅ Tamamlandı. Artık servis sorunsuz açılmalı." -ForegroundColor Green
