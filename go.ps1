#Requires -RunAsAdministrator

$CfgPath = ".\config.xml"

if (Test-Path $CfgPath -PathType Leaf) {
    [xml]$ConfigFile = Get-Content $CfgPath
} else {
    Write-Host "! Config file not found at '$CfgPath', exiting."
    exit 1
}

# Code "borrowed" from Microsoft
Write-Host "Installing WinGet..."
$progressPreference = 'silentlyContinue'
$latestWingetMsixBundleUri = $(Invoke-RestMethod https://api.github.com/repos/microsoft/winget-cli/releases/latest).assets.browser_download_url | Where-Object { $_.EndsWith(".msixbundle") }
$latestWingetMsixBundle = $latestWingetMsixBundleUri.Split("/")[-1]
Write-Information "Downloading winget to artifacts directory..."
Invoke-WebRequest -Uri $latestWingetMsixBundleUri -OutFile "./$latestWingetMsixBundle"
Invoke-WebRequest -Uri https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx -OutFile Microsoft.VCLibs.x64.14.00.Desktop.appx
Add-AppxPackage Microsoft.VCLibs.x64.14.00.Desktop.appx
Add-AppxPackage $latestWingetMsixBundle

<#  9p7knl5rwt25 = Sysinternals
    9N0DX20HK701 = Windows Terminal #>
$theShitWinGet = $ConfigFile.Settings.Install.Object

# 549981C3F5F10 = Cortana
$theShittyShit = $ConfigFile.Settings.Uninstall.Object

$tz = $ConfigFile.Settings.TimeZone

Write-Host "The following will be installed:"
foreach ($package in $theShitWinGet) {
  Write-Host "$package" -ForegroundColor Yellow
}
Read-Host -Prompt "Press any key to continue"
foreach ($package in $theShitWinGet) {
  winget install $package --accept-package-agreements
}
Read-Host -Prompt "Done, press any key to proceed to bloatware app uninstallation"
Write-Host "The following will be uninstalled:"
foreach ($shit in $theShittyShit) {
  if (Get-AppxPackage -Name "$shit") {
    Write-Host "$shit" -ForegroundColor Yellow
  }
}
Read-Host -Prompt "Press any key to continue"
Write-Host "Backing up list of all installed apps. File will be placed at '$($pwd.Path)\InstalledBefore.txt'."
Get-AppxPackage -AllUsers > InstalledBefore.txt
Write-Host "Removing applications"
foreach ($shit in $theShittyShit) {
  if (Get-AppxPackage -Name "$shit") {
    Get-AppxPackage $shit -AllUsers | Remove-AppxPackage
  }
}

Write-Host "Setting Time Zone to '$tz'"
Set-TimeZone -Id "$tz"

Read-Host -Prompt "All done! Press any key to exit"