powershell.exe Install-WindowsFeature -name Web-Server -IncludeManagementTools
powershell.exe Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
powershell.exe choco install rabbitmq cup all -y
powershell.exe docker pull mcr.microsoft.com/dotnet/core/samples:aspnetapp
powershell.exe docker run -d --rm -p 5000:80 --name aspnetcore_sample mcr.microsoft.com/dotnet/core/samples:aspnetapp
powershell.exe remove-item 'C:\\inetpub\\wwwroot\\iisstart.htm'
powershell.exe Add-Content -Path 'C:\\inetpub\\wwwroot\\iisstart.htm' -Value $('Hello World from ' + $env:computername)
