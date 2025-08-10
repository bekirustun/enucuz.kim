# scripts\user-crud-demo.ps1
# Full CRUD (Create→Read→Update→Delete) demo for user-service via gateway
# Esma love pack 💙

$ErrorActionPreference = "Stop"

# == Ayarlar ==
$Gateway = "http://localhost:3015"
$BaseUrl = "$Gateway/api/users"

function Invoke-Api {
  param(
    [Parameter(Mandatory)][ValidateSet("GET","POST","PATCH","PUT","DELETE")]$Method,
    [Parameter(Mandatory)][string]$Url,
    [string]$JsonBody
  )
  if ($JsonBody) {
    return (iwr $Url -Method $Method -Body $JsonBody -ContentType "application/json" | Select-Object -ExpandProperty Content)
  } else {
    return (iwr $Url -Method $Method | Select-Object -ExpandProperty Content)
  }
}

function Extract-Id {
  param($jsonText)
  $obj = $jsonText | ConvertFrom-Json
  if ($null -ne $obj.id) { return $obj.id }
  if ($null -ne $obj.data -and $null -ne $obj.data.id) { return $obj.data.id }
  return $null
}

Write-Host "== Health ==" -ForegroundColor Cyan
try {
  $health = Invoke-Api -Method GET -Url "$BaseUrl/health"
  Write-Host $health -ForegroundColor Green
} catch {
  Write-Host "Gateway ya da user-service ayakta değil gibi: $($_.Exception.Message)" -ForegroundColor Red
  throw
}

Write-Host "`n== LIST (ilk durum) ==" -ForegroundColor Cyan
Invoke-Api -Method GET -Url $BaseUrl | Out-Host

Write-Host "`n== CREATE ==" -ForegroundColor Cyan
$uniq = [DateTime]::UtcNow.ToString("yyyyMMddHHmmss")
$createJson = (@{
  name  = "Grace Hopper"
  email = "grace+$uniq@example.com"
  role  = "admin"
} | ConvertTo-Json)

$createRes = Invoke-Api -Method POST -Url $BaseUrl -JsonBody $createJson
Write-Host "CREATE response:" -ForegroundColor DarkCyan
$createRes | Out-Host

$cid = Extract-Id $createRes
if (-not $cid) { throw "CREATE döndü ama ID bulunamadı." }
Write-Host ("Created ID: {0}" -f $cid) -ForegroundColor Green

Write-Host "`n== READ (by id) ==" -ForegroundColor Cyan
Invoke-Api -Method GET -Url "$BaseUrl/$cid" | Out-Host

Write-Host "`n== UPDATE (PATCH→PUT fallback) ==" -ForegroundColor Cyan
$updateJson = (@{
  name  = "Grace Hopper (updated)"
  email = "grace.updated+$uniq@example.com"
  role  = "editor"
} | ConvertTo-Json)

$updatedJson = $null
try {
  $updatedJson = Invoke-Api -Method PATCH -Url "$BaseUrl/$cid" -JsonBody $updateJson
  Write-Host "PATCH başarılı." -ForegroundColor Green
} catch {
  Write-Host "PATCH desteklenmiyor; PUT deniyorum..." -ForegroundColor Yellow
  $updatedJson = Invoke-Api -Method PUT -Url "$BaseUrl/$cid" -JsonBody $updateJson
  Write-Host "PUT başarılı." -ForegroundColor Green
}
$updatedJson | Out-Host

Write-Host "`n== READ (kontrol) ==" -ForegroundColor Cyan
Invoke-Api -Method GET -Url "$BaseUrl/$cid" | Out-Host

Write-Host "`n== DELETE ==" -ForegroundColor Cyan
Invoke-Api -Method DELETE -Url "$BaseUrl/$cid" | Out-Host

Write-Host "`n== LIST (son durum) ==" -ForegroundColor Cyan
Invoke-Api -Method GET -Url $BaseUrl | Out-Host

Write-Host "`nBitti. CRUD akışı sorunsuz tamamlandı. 💙" -ForegroundColor Green
