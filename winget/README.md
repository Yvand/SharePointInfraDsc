# Winget configuration files

Winget configurations to custmize Windows and install various packages useful for working with SharePoint and doing dev / debug / troublshooting.

# Install via a script

```powershell
$urls = @(
   "https://raw.githubusercontent.com/Yvand/SharePointInfraDsc/refs/heads/main/winget/winget_windows_settings.winget",
   "https://raw.githubusercontent.com/Yvand/SharePointInfraDsc/refs/heads/main/winget/winget_packages_extended.winget",
   "https://github.com/Yvand/SharePointInfraDsc/blob/main/winget/winget_vscode.winget"
)
foreach ($url in $urls) {
   $uri = New-Object Uri($url)
   Invoke-WebRequest -Uri $uri -OutFile $uri.Segments[-1]
   Write-Host -ForegroundColor Blue "Applying config in '$($uri.Segments[-1])'..."
   winget configure --file $uri.Segments[-1] --accept-configuration-agreements
}
```

