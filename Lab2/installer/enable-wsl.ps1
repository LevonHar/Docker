$log = "D:\Docker\Lab2\installer\wsl-enable.log"
function Log([string]$Message) {
    Add-Content -Path $log -Value ("{0} {1}" -f (Get-Date -Format o), $Message)
}

"WSL enable started" | Set-Content -Path $log
Log "user=$env:USERNAME elevated check"

$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
Log "isAdmin=$isAdmin"

Log "enabling Microsoft-Windows-Subsystem-Linux"
$out1 = & dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart 2>&1 | Out-String
Log $out1

Log "enabling VirtualMachinePlatform"
$out2 = & dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart 2>&1 | Out-String
Log $out2

$reboot = $false
if (Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending") { $reboot = $true }
if (Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired") { $reboot = $true }
Log "rebootPending=$reboot"
Log "done"
exit 0
