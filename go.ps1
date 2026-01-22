#Requires -RunAsAdministrator

# TODO: Filter the XML by whether or not an app is installed already

# Just in case someone doesn't get the memo
if ($Env:OS -ne 'Windows_NT') {
  Write-Host "This script will only run on Windows, exiting."
  exit 1
}

$CfgPath = ".\config.xml"

if (Test-Path $CfgPath -PathType Leaf) {
  [xml]$ConfigFile = Get-Content $CfgPath
}
else {
  Write-Host "! Config file not found at '$CfgPath', exiting."
  exit 1
}

$Unattended = $ConfigFile.Settings.ASS.Unattended
$RegistryImport = $ConfigFile.Settings.ASS.RegistryFile

if ($RegistryImport) {
  if ($Unattended -eq "True" -or $(Read-Host "Would you like to import your registry settings from '$RegistryImport'?") -eq 'y') {
    if ($ConfigFile.Settings.ASS.RegistryBackup -eq "True") {
      $RegistryBackupName = "FullRegBackup$(Get-Date -Format o | ForEach-Object { $_ -replace ":", "." }).reg"
      Write-Host "Backing up the registry to '$RegistryBackupName'"
      reg export HKLM "$RegistryBackupName"
    }
    Write-Host "Importing '$RegistryImport'"
    reg import "$RegistryImport"
  }
}

if ($ConfigFile.Settings.ASS.InstallWinget -eq "True") {
  # Code "borrowed" from Microslop
  Write-Host "Installing Winget..."
  $progressPreference = 'silentlyContinue'
  $latestWingetMsixBundleUri = $(Invoke-RestMethod https://api.github.com/repos/microsoft/winget-cli/releases/latest).assets.browser_download_url | Where-Object { $_.EndsWith(".msixbundle") }
  $latestWingetMsixBundle = $latestWingetMsixBundleUri.Split("/")[-1]
  Write-Information "Downloading Winget to artifacts directory..."
  Invoke-WebRequest -Uri $latestWingetMsixBundleUri -OutFile "./$latestWingetMsixBundle"
  Invoke-WebRequest -Uri https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx -OutFile Microsoft.VCLibs.x64.14.00.Desktop.appx
  Add-AppxPackage Microsoft.VCLibs.x64.14.00.Desktop.appx
  Add-AppxPackage $latestWingetMsixBundle
}

$InstallMe = $ConfigFile.Settings.Install.Package | Sort-Object

# 549981C3F5F10 = Cortana
$UninstallMe = $ConfigFile.Settings.Uninstall.Package | Sort-Object

$tz = $ConfigFile.Settings.System.TimeZone

Write-Host "The following will be installed:"
foreach ($package in $InstallMe) {
  if ($package.comment) {
    Write-Host "$($package.InnerText)`t`t`t`t`"$($package.comment)`"" -ForegroundColor Yellow
  }
  else {
    Write-Host $package -ForegroundColor Yellow
  }
}
if ($Unattended -eq "True" -or $(Read-Host "Would you like to install these apps? (y/n)") -eq 'y') {
  foreach ($package in $InstallMe) {
    if ($package.comment) {
      winget install $package.InnerText --accept-package-agreements
    }
    else {
      winget install $package --accept-package-agreements
    }
  }
}
Write-Host "The following will be uninstalled:"
foreach ($package in $UninstallMe) {
  if ($package.comment) {
    Write-Host "$($package.InnerText)`t`t`t`t`"$($package.comment)`"" -ForegroundColor Red
  }
  else {
    Write-Host $package -ForegroundColor Red
  }
}

if ($Unattended -eq "True" -or $(Read-Host "Would you like to uninstall these apps? (y/n)") -eq 'y') {
  Write-Host "Backing up list of all installed apps to '$($pwd.Path)\InstalledBefore.txt'."
  Get-AppxPackage -AllUsers > InstalledBefore.txt
  Write-Host "Uninstalling applications"
  foreach ($package in $UninstallMe) {
    if ($package.comment) {
      Get-AppxPackage $package.InnerText -AllUsers | Remove-AppxPackage
    }
    else {
      Get-AppxPackage $package -AllUsers | Remove-AppxPackage
    }
  }
}

Write-Host "Setting Time Zone to '$tz'"
Set-TimeZone -Id "$tz"

Read-Host -Prompt "All done! Press enter to exit"