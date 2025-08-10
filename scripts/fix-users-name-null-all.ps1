# fix-users-name-null-all.ps1
# Tüm DB'lerde (template olmayan) public.users varsa name kolonunu güvenli şekilde NOT NULL yapar.

param(
  [string]$EnvFile = "D:\U\S\enucuz.kim\services\user-service\.env"
)

function Get-PsqlPath {
  $cmd = Get-Command psql.exe -ErrorAction SilentlyContinue
  if($cmd){ return $cmd.Source }
  $paths = @(
    "D:\PostgreSQL\bin\psql.exe",
    "C:\Program Files\PostgreSQL\17\bin\psql.exe",
    "C:\Program Files\PostgreSQL\16\bin\psql.exe",
    "C:\Program Files\PostgreSQL\15\bin\psql.exe"
  )
  $found = $paths | ? { Test-Path $_ } | Select-Object -First 1
  if($found){ return $found }
  throw "psql.exe bulunamadı."
}

function Read-DotEnv($path){
  if(-not (Test-Path $path)){ throw ".env bulunamadı: $path" }
  $map=@{}; Get-Content $path | %{
    if($_ -match '^\s*#|^\s*$'){ return }
    $k,$v = $_ -split '=',2; $map[$k.Trim()]=$v.Trim()
  }; return $map
}

$envmap = Read-DotEnv $EnvFile
$DB_HOST = $envmap["DB_HOST"]; if(-not $DB_HOST){ $DB_HOST="localhost" }
$DB_PORT = $envmap["DB_PORT"]; if(-not $DB_PORT){ $DB_PORT="5432" }
$DB_USER = $envmap["DB_USER"]; if(-not $DB_USER){ $DB_USER="postgres" }
$DB_PASS = $envmap["DB_PASS"]; if(-not $DB_PASS){ throw "DB_PASS .env içinde yok" }

$psql = Get-PsqlPath
$env:PGPASSWORD = $DB_PASS
Write-Host ("psql -> {0}" -f $psql)

# DB listesi (template olmayanlar)
$dbs = & $psql -U $DB_USER -h $DB_HOST -p $DB_PORT -d postgres -t -A -c "SELECT datname FROM pg_database WHERE datistemplate=false;"
$dbs = $dbs | ? { $_ -and $_.Trim() -ne "" }

foreach($db in $dbs){
  Write-Host "`n=== DB: $db ===" -ForegroundColor Cyan
  # users tablosu var mı?
  $hasTable = & $psql -U $DB_USER -h $DB_HOST -p $DB_PORT -d $db -t -A -c "SELECT to_regclass('public.users') IS NOT NULL;"
  if($hasTable.Trim() -ne "t"){
    Write-Host "public.users yok, atlanıyor." -ForegroundColor DarkYellow
    continue
  }

  $steps = @(
    "ALTER TABLE public.users ADD COLUMN IF NOT EXISTS name varchar(120) DEFAULT 'Unknown';",
    "UPDATE public.users SET name = 'Unknown' WHERE name IS NULL;",
    "ALTER TABLE public.users ALTER COLUMN name SET NOT NULL;",
    "ALTER TABLE public.users ALTER COLUMN name DROP DEFAULT;"
  )
  foreach($sql in $steps){
    Write-Host "SQL: $sql" -ForegroundColor Yellow
    & $psql -U $DB_USER -h $DB_HOST -p $DB_PORT -d $db -v ON_ERROR_STOP=1 -c "$sql"
    if($LASTEXITCODE -ne 0){ throw "❌ $db komut hatası (exit $LASTEXITCODE)" }
  }
  Write-Host "✅ $db tamam." -ForegroundColor Green
}
Write-Host "`nBitti." -ForegroundColor Green
