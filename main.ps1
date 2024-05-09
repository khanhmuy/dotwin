# Basiaclly an automated version of WindowsToolbox, add or remove any functions that you want/don't want to use.
# It's shit but it works -me, just now.
# this thing is so janky lmao

# Self-elevate the script if required
$myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID)
$adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator
if (-not $myWindowsPrincipal.IsInRole($adminRole))
   {
       $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";
       $newProcess.Arguments = $myInvocation.MyCommand.Definition;
       $newProcess.Verb = "runas";
       [System.Diagnostics.Process]::Start($newProcess) | Out-Null
       exit
   }
#God fucking knows if this works
Set-ExecutionPolicy Unrestricted -Scope CurrentUser
Get-ChildItem -Recurse *.ps*1 | Unblock-File
Set-Location $PSScriptRoot

Clear-Host
Import-Module .\library\Write-Menu.psm1 -DisableNameChecking
Import-Module .\library\WinCore.psm1 -DisableNameChecking
Import-Module .\library\PrivacyFunctions.psm1 -DisableNameChecking
Import-Module .\library\Tweaks.psm1 -DisableNameChecking
Import-Module .\library\GeneralFunctions.psm1 -DisableNameChecking
Import-Module .\library\DebloatFunctions.psm1 -DisableNameChecking

setup
Write-Output "This is basically an automated version of WindowsToolbox, add or remove any functions that you want/don't want before running. You should have read the code beforehand anyway."
Write-Output "It's shit but it (barely) works -me, some 2 years ago."
Write-Output "This script assumes winget is present."
Read-Host "Press enter to continue!"

#Force TLS 1.2 for chocolatey support
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

#Create a system restore point
Enable-ComputerRestore -Drive "$env:SystemDrive"
Checkpoint-Computer -Description "BeforePostInstall" -RestorePointType "MODIFY_SETTINGS"

#Install chocolatey
InstallChoco

Clear-Host

Write-Host "Select:"
$objects = @(
    '1) Debloat', 
    '2) Privacy fixes',
    '3) Tweaks',
    '4) Install programs',
    '5) Install configs',
    '6) Reboot'
)

while ($true) {
    $mainMenu = Write-Menu -Sort -Title $title -Entries $objects
    switch ($mainMenu) {
        "1) Debloat" {
            Write-Output "Debloating..."
            RemoveOneDrive
            RemoveDefaultApps
            DisableCortana
            RemoveIE
            RemoveXboxBloat
        }
        "2) Privacy fixes" {
            Write-Output "Applying privacy fixes..."
            DisableTelemetry
            PrivacyFixSettings
            DisableAppSuggestions
            DisableTailoredExperiences
            DisableAdvertisingID
            DisableActivityHistory
        }
        "3) Tweaks" {
            Write-Output "Applying tweaks..."
            RAM
            DisablePrefetchPrelaunch
            DisableEdgePrelaunch
            DisableSuperfetch
            UseUTC
            DisablePageFileEncryption
            ShowExplorerFullPath
            SetExplorerThisPC
            ShowFileExtensions
            TBSingleClick
            DisableAccessibilityKeys
            SetWinXMenuCMD
            EnableVerboseStartup
            EnableClassicMenu
            Write-Output "Killing Explorer process..."
            taskkill.exe /F /IM "explorer.exe"
            Write-Output "Restarting Explorer..."
            Start-Process "explorer.exe"
            Write-Output "Waiting for explorer to complete loading"
            Start-Sleep 10
        }
        "4) Install programs" {
            Write-Output "Installing apps..."
            winget install --accept-package-agreements --ignore-unavailable --ignore-versions -e .\packages.json
            refreshenv
        }
        "5) Install configs" {
            $gh = "C:\Users\$env:username\Documents\gh"
            New-Item -Path $gh -ItemType directory -Force
            Set-Location $gh
            
            $terminalSettings = "C:\Users\$env:username\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
            Copy-Item $PSScriptRoot\configs\terminal\settings.json -Destination $terminalSettings
            Copy-Item $PSScriptRoot\configs\pwsh\Microsoft.PowerShell_profile.psm1 -Destination $env:USERPROFILE\Documents\WindowsPowerShell
            Copy-Item $PSScriptRoot\configs\pwsh\candy_custom.omp.json -Destination $env:USERPROFILE
        }
        "6) Reboot" {
            $confirm = Read-Host "Are you sure you want to restart? (y/n) Remember to save your work first."
            if($confirm -eq "y") {
                Restart-Computer
            }
        }
    }
    Read-Host "Press Enter To Continue"
    Clear-Host
}