del "c:\inetpub\wwwroot\*.html" /s /f /q

REM Install Internet Information Server (IIS).
c:\Windows\Sysnative\WindowsPowerShell\v1.0\powershell.exe -Command Import-Module -Name ServerManager
c:\Windows\Sysnative\WindowsPowerShell\v1.0\powershell.exe -Command Install-WindowsFeature Web-Server

c:\Windows\Sysnative\WindowsPowerShell\v1.0\powershell.exe -Command Set-NetFirewallRule -Name "WINRM-HTTP-In-TCP-PUBLIC" -RemoteAddress Any
c:\Windows\Sysnative\WindowsPowerShell\v1.0\powershell.exe -Command Enable-PSRemoting