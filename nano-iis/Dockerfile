# escape=`

FROM microsoft/aspnetcore:2.0.0-nanoserver As CoreBuild

FROM microsoft/aspnetcore-build:2.0.0-nanoserver As builder
WORKDIR /source/
COPY source/iis .
RUN dotnet restore; dotnet publish -c Release

From microsoft/iis as WindowsBuild
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'Continue'; $verbosePreference='Continue';"]
ADD https://download.microsoft.com/download/B/1/D/B1D7D5BF-3920-47AA-94BD-7A6E48822F18/DotNetCore.2.0.0-WindowsHosting.exe ".\hosting.exe"
RUN start-process -Filepath .\hosting.exe -ArgumentList @('/install', '/quiet', '/norestart') -Wait 


FROM microsoft/iis:nanoserver
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'Continue'; $verbosePreference='Continue';"]
RUN start-process -Filepath dism.exe -ArgumentList  @('/online', '/enable-feature:IIS-WindowsAuthentication', '/ALL') -Wait  
RUN setx /M PATH $($Env:PATH + ';' + $Env:ProgramFiles + '\dotnet')
COPY --from=CoreBuild ["c:\\Program Files\\dotnet", "c:\\program files\\dotnet"]
COPY --from=WindowsBuild ["c:\\Windows\\System32\\inetsrv\\aspnetcore.dll", "c:\\Windows\\System32\\inetsrv\\"]
COPY --from=WindowsBuild ["c:\\Windows\\System32\\inetsrv\\config\\schema\\aspnetcore_schema.xml",  "c:\\Windows\\System32\\inetsrv\\config\\schema\\"]
WORKDIR app
ADD configure.ps1 .
RUN .\configure.ps1
RUN  new-LocalUser -Name "ContainerAdmin" -Password  (ConvertTo-SecureString  "A123456!" -AsPlainText -Force); `
     Add-LocalGroupMember -Group Administrators -Member "ContainerAdmin" ; 
RUN Import-Module IISAdministration; Start-IISCommitDelay; (Get-IISServerManager).ApplicationPools['DefaultAppPool'].ProcessModel.IdentityType='LocalSystem'; `
    (Get-IISServerManager).Sites[0].Applications[0].VirtualDirectories[0].PhysicalPath = 'c:\app'; (Get-IISConfigSection -SectionPath 'system.webServer/security/authentication/windowsAuthentication').Attributes['enabled'].value = $true; `
    Stop-IISCommitDelay
EXPOSE 80
COPY --from=builder /source/bin/Release/netcoreapp2.0/publish .


