$ErrorActionPreference = "Continue"
$log = "D:\Docker\Lab2\run-result.txt"
function Log([string]$Message) {
    $line = "{0} {1}" -f (Get-Date -Format o), $Message
    Add-Content -Path $log -Value $line
}

Set-Content -Path $log -Value "Lab2 first container run"
Log "start user=$env:USERNAME"

$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

Log "wsl --version:"
& wsl.exe --version 2>&1 | ForEach-Object { Log "$_" }
Log "wsl --status:"
& wsl.exe --status 2>&1 | ForEach-Object { Log "$_" }

$desktop = "C:\Program Files\Docker\Docker\Docker Desktop.exe"
if (-not (Get-Process -Name "Docker Desktop" -ErrorAction SilentlyContinue)) {
    Log "starting Docker Desktop"
    Start-Process -FilePath $desktop
} else {
    Log "Docker Desktop already running"
}

$ready = $false
for ($i = 1; $i -le 60; $i++) {
    & docker info *> $null
    if ($LASTEXITCODE -eq 0) {
        $ready = $true
        Log "engine ready on attempt $i"
        break
    }
    Log "waiting for engine attempt $i"
    Start-Sleep -Seconds 10
}

if (-not $ready) {
    Log "engine not ready"
    & docker version 2>&1 | ForEach-Object { Log "$_" }
    exit 1
}

Set-Location "D:\Docker\Lab2"
Log "docker build -t lab2-hello ."
& docker build -t lab2-hello . 2>&1 | ForEach-Object { Log "$_" }
if ($LASTEXITCODE -ne 0) {
    Log "build failed exit=$LASTEXITCODE"
    exit 1
}

& docker rm -f lab2-hello *> $null
Log "docker run -d --name lab2-hello -p 8080:8080 lab2-hello"
& docker run -d --name lab2-hello -p 8080:8080 lab2-hello 2>&1 | ForEach-Object { Log "$_" }
if ($LASTEXITCODE -ne 0) {
    Log "run failed exit=$LASTEXITCODE"
    exit 1
}

Start-Sleep -Seconds 2
try {
    $resp = Invoke-WebRequest -Uri "http://127.0.0.1:8080/" -UseBasicParsing
    Log "HTTP $($resp.StatusCode) body=$($resp.Content.Trim())"
} catch {
    Log "HTTP request failed: $($_.Exception.Message)"
}

Log "docker ps:"
& docker ps --filter "name=lab2-hello" 2>&1 | ForEach-Object { Log "$_" }
Log "docker images:"
& docker images lab2-hello 2>&1 | ForEach-Object { Log "$_" }
Log "done"

$startup = Join-Path $env:APPDATA "Microsoft\Windows\Start Menu\Programs\Startup\lab2-docker-first-run.cmd"
Remove-Item -Path $startup -ErrorAction SilentlyContinue
Log "removed startup launcher"
exit 0
