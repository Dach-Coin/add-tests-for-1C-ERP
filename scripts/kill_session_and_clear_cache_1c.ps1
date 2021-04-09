Start-Sleep -Seconds 2

Get-WMIObject Win32_Process|Where-Object{$_.name -eq '1cv8.exe'-and $_.getowner().user -eq $env:UserName }|ForEach-Object{stop-process $_.ProcessId}
Get-WMIObject Win32_Process|Where-Object{$_.name -eq '1cv8c.exe'-and $_.getowner().user -eq $env:UserName }|ForEach-Object{stop-process $_.ProcessId}
Get-WMIObject Win32_Process|Where-Object{$_.name -eq '1cv8s.exe'-and $_.getowner().user -eq $env:UserName }|ForEach-Object{stop-process $_.ProcessId}

$path = "$env:USERPROFILE\\AppData\\Local\\1C\\1Cv8"
if (Test-Path $path)
	{
	Remove-Item $path -Force -Recurse
	}
		
$path = "$env:USERPROFILE\\AppData\\Local\\1C\\1Cv82"
if (Test-Path $path)
	{
	Remove-Item $path -Force -Recurse
	}

$path = "$env:USERPROFILE\\AppData\\Roaming\\1C\\1cv8"
if (Test-Path $path)
	{
	Remove-Item $path -Force -Recurse
	}

$path = "$env:USERPROFILE\\AppData\\Roaming\\1C\\1Cv82"
if (Test-Path $path)
	{
	Remove-Item $path -Force -Recurse
    }

Start-Sleep -Seconds 5    