Install-WindowsFeature -name Web-Server -IncludeManagementTools
remove-item 'C:\inetpub\wwwroot\iisstart.htm' -confirm:$false -Force
Add-Content -Path 'C:\inetpub\wwwroot\iisstart.htm' -Value $('Hello World from ' + $env:computername)
docker pull mcr.microsoft.com/dotnet/core/samples:aspnetapp
# docker run -d --rm -p 5000:80 --name aspnetcore_sample mcr.microsoft.com/dotnet/core/samples:aspnetapp
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
# choco install rabbitmq cup all -y
# cd 'c:\Program Files\RabbitMQ Server\rabbitmq_server-3.8.5\sbin'
# .\rabbitmq-plugins enable rabbitmq_management
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest "https://github.com/docker/compose/releases/download/1.26.2/docker-compose-Windows-x86_64.exe" -UseBasicParsing -OutFile $Env:ProgramFiles\Docker\docker-compose.exe
#docker pull olandese/rabbit-qs2
docker run -d -p 15672:15672 -p 5672:5672 --name rabbitmq olandese/rabbit-qs2
docker run -dt -p 5000:80 --name rabbit olandese/rabbit
