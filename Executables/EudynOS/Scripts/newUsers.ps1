$title = 'Preparing user settings...'

$Host.UI.RawUI.WindowTitle = $title
Write-Host $title -ForegroundColor Yellow
Write-Host $('-' * ($title.length + 3)) -ForegroundColor Yellow
Write-Host 'You''ll be logged out in 10 to 20 seconds, and once you login again, your new account will be ready for use.'

# Disable Windows 11 context menu & 'Gallery' in File Explorer
if ([System.Environment]::OSVersion.Version.Build -ge 22000) {
    reg import "$env:windir\EudynOS\Scripts\File Explorer Customization\Gallery\Disable Gallery (default).reg" *>$null
}

# Pin 'Videos' and 'Music' folders to Home/Quick Acesss
$o = new-object -com shell.application
$o.Namespace("$env:userprofile\Videos").Self.InvokeVerb('pintohome')
$o.Namespace("$env:userprofile\Music").Self.InvokeVerb('pintohome')

# Set taskbar search box to an icon
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Value 1

# Leave
Start-Sleep 5
logoff