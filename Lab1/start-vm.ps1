$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$Qemu = Join-Path $Root "qemu\qemu-system-x86_64.exe"
$Disk = Join-Path $Root "vm\disk.qcow2"
$Seed = Join-Path $Root "vm\seed.iso"
$Serial = Join-Path $Root "vm\serial.log"

if (-not (Test-Path $Qemu)) { throw "QEMU not found: $Qemu" }
if (-not (Test-Path $Disk)) { throw "Disk not found: $Disk" }

$hypervisor = (Get-CimInstance Win32_ComputerSystem).HypervisorPresent
if ($env:LAB1_ACCEL) {
    $accel = $env:LAB1_ACCEL
} elseif ($hypervisor) {
    $accel = "whpx"
} else {
    $accel = "tcg"
}

$args = @(
    "-name", "ubuntu-server",
    "-machine", "q35,accel=$accel",
    "-cpu", $(if ($accel -eq "whpx") { "host" } else { "max" }),
    "-m", "2048",
    "-smp", "2",
    "-display", "none",
    "-vga", "none",
    "-boot", "order=c",
    "-serial", "file:$Serial",
    "-monitor", "none",
    "-drive", "file=$($Disk -replace '\\','/'),if=virtio,format=qcow2,discard=unmap",
    "-drive", "file=$($Seed -replace '\\','/'),media=cdrom,format=raw,if=virtio,readonly=on",
    "-netdev", "user,id=net0,hostfwd=tcp:127.0.0.1:2222-:22,hostfwd=tcp:127.0.0.1:8080-:80",
    "-device", "virtio-net-pci,netdev=net0",
    "-device", "virtio-rng-pci"
)

Write-Output "Starting Ubuntu Server with accel=$accel"
& $Qemu @args
exit $LASTEXITCODE
