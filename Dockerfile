# escape=`
FROM microsoft/aspnetcore-build:2.0.0-nanoserver As Builder
WORKDIR /source/
COPY source/iis .
RUN dotnet restore; dotnet publish -c Release




FROM microsoft/aspnetcore:2.0.0-nanoserver
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'Continue'; $verbosePreference='Continue';"]
ADD https://az880830.vo.msecnd.net/nanoserver-ga-2016/Microsoft-NanoServer-IIS-Package_base_10-0-14393-0.cab /install/Microsoft-NanoServer-IIS-Package_base_10-0-14393-0.cab
ADD https://az880830.vo.msecnd.net/nanoserver-ga-2016/Microsoft-NanoServer-IIS-Package_English_10-0-14393-0.cab /install/Microsoft-NanoServer-IIS-Package_English_10-0-14393-0.cab
RUN start-process -Filepath dism.exe -ArgumentList  @('/online', '/add-package', '/packagepath:c:\install\Microsoft-NanoServer-IIS-Package_base_10-0-14393-0.cab') -Wait 
RUN start-process -Filepath dism.exe -ArgumentList  @('/online', '/add-package', '/packagepath:c:\install\Microsoft-NanoServer-IIS-Package_English_10-0-14393-0.cab') -Wait 
RUN start-process -Filepath dism.exe -ArgumentList  @('/online', '/add-package', '/packagepath:c:\install\Microsoft-NanoServer-IIS-Package_base_10-0-14393-0.cab') -Wait 
RUN start-process -Filepath dism.exe -ArgumentList  @('/online', '/enable-feature:IIS-WindowsAuthentication', '/ALL') -Wait  
RUN remove-item "c:\\install" -force -Recurse
COPY ["aspnetcore.dll", "c:\\Windows\\System32\\inetsrv\\"]
COPY ["aspnetcore_schema.xml",  "c:\\Windows\\System32\\inetsrv\\config\\schema\\"]
WORKDIR app
ADD configure.ps1 .
RUN .\configure.ps1
RUN Import-Module IISAdministration; Start-IISCommitDelay; (Get-IISServerManager).ApplicationPools['DefaultAppPool'].ProcessModel.IdentityType='LocalSystem'; `
    (Get-IISServerManager).Sites[0].Applications[0].VirtualDirectories[0].PhysicalPath = 'c:\app'; (Get-IISConfigSection -SectionPath 'system.webServer/security/authentication/windowsAuthentication').Attributes['enabled'].value = $true; `
    Stop-IISCommitDelay
EXPOSE 80
COPY --from=builder /source/bin/Release/netcoreapp2.0/publish .
ADD ["\\bin\\spinner.exe", "\\bin\\web.config",  "./"] 
ENTRYPOINT ["spinner.exe", "service", "W3SVC"]
