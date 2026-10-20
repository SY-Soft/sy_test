# start1.ps1
# Умный старт MySQL на bind-mount (Windows + внешний SSD / NTFS)
# - если данные уже инициализированы → просто поднимаем стек
# - если папка пустая/битая → делаем init через временный volume, потом поднимаем

$ErrorActionPreference = "Continue"

$StackDir     = $PSScriptRoot
$MysqlHostDir = Join-Path (Split-Path $StackDir -Parent) "mysql"
$TmpVolume    = "mysql_init_tmp_$(Get-Random)"
$TmpContainer = "mysql_init_tmp"

function Test-MysqlInitialized {
    param([string]$Dir)

    $required = @(
        "ibdata1",
        "mysql",
        "ca.pem",
        "server-cert.pem",
        "server-key.pem",
        "private_key.pem",
        "public_key.pem"
    )

    foreach ($item in $required) {
        if (-not (Test-Path (Join-Path $Dir $item))) {
            return $false
        }
    }
    return $true
}

Write-Host "==> MySQL data dir: $MysqlHostDir"

# Создаём папку, если нет
if (-not (Test-Path $MysqlHostDir)) {
    New-Item -ItemType Directory -Path $MysqlHostDir | Out-Null
}

# ============================================
# Уже инициализировано → просто поднимаем стек
# ============================================
if (Test-MysqlInitialized $MysqlHostDir) {
    Write-Host "==> MySQL data already initialized."
    Write-Host "==> Starting stack..."
    Set-Location $StackDir
    docker compose up --build -d
    exit $LASTEXITCODE
}

# ============================================
# Нужна инициализация
# ============================================
Write-Host "==> Data directory empty or incomplete. Starting full init..."

# Останавливаем всё, что могло остаться
Write-Host "==> docker compose down..."
Set-Location $StackDir
docker compose down 2>$null | Out-Null

# Чистим мусор в папке
Write-Host "==> Cleaning $MysqlHostDir ..."
Get-ChildItem -Path $MysqlHostDir -Force -ErrorAction SilentlyContinue |
    Remove-Item -Recurse -Force -ErrorAction SilentlyContinue

# Удаляем старый временный контейнер
docker rm -f $TmpContainer 2>$null | Out-Null

# Создаём временный volume
Write-Host "==> Creating temporary volume: $TmpVolume"
docker volume create $TmpVolume | Out-Null

# Запускаем временный MySQL
Write-Host "==> Starting temporary MySQL container..."
docker run -d --name $TmpContainer `
    -e MYSQL_ROOT_PASSWORD=root `
    -v "${TmpVolume}:/var/lib/mysql" `
    mysql:8.0 `
    --lower-case-table-names=1 | Out-Null

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: failed to start temporary MySQL container"
    exit 1
}

# Ждём инициализации
Write-Host "==> Waiting for MySQL to initialize (max 90 sec)..."
$ready = $false
for ($i = 1; $i -le 45; $i++) {
    Start-Sleep -Seconds 2

    $logs = & docker logs $TmpContainer 2>&1 | Out-String

    if ($logs -match "ready for connections" -or $logs -match "MySQL init process done") {
        $ready = $true
        break
    }

    if ($logs -match "\[ERROR\].*Aborting" -or $logs -match "Data Dictionary initialization failed") {
        Write-Host $logs
        break
    }

    Write-Host "  ... waiting ($i/45)"
}

if (-not $ready) {
    Write-Host "ERROR: MySQL failed to initialize in time"
    & docker logs $TmpContainer 2>&1
    docker rm -f $TmpContainer 2>$null | Out-Null
    docker volume rm $TmpVolume 2>$null | Out-Null
    exit 1
}

Write-Host "==> MySQL initialized. Copying data to host..."

# Останавливаем временный контейнер
docker stop $TmpContainer | Out-Null
docker rm $TmpContainer | Out-Null

# Копируем на хост + правим владельца
docker run --rm `
    -v "${TmpVolume}:/from" `
    -v "${MysqlHostDir}:/to" `
    alpine sh -c "cp -a /from/. /to/ && chown -R 999:999 /to"

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: failed to copy data to host"
    docker volume rm $TmpVolume 2>$null | Out-Null
    exit 1
}

# Чистим временный volume
docker volume rm $TmpVolume | Out-Null

Write-Host "==> Data copied successfully."

# ============================================
# Поднимаем весь стек
# ============================================
Write-Host "==> Starting full stack..."
Set-Location $StackDir
docker compose up --build -d

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "==> Done."
    Write-Host "    MySQL data: $MysqlHostDir"
    Write-Host "    phpMyAdmin: http://localhost:8080  (root / root)"
    Write-Host ""
} else {
    Write-Host "ERROR: docker compose up failed"
    exit 1
}