# escape=`

# Image with NET CORE installation to extract executables for final image
FROM microsoft/aspnetcore:2.0.0-nanoserver As CoreBuild


# Image with SDK to build .NET Core application from source
FROM microsoft/aspnetcore-build:2.0.0-nanoserver As builder
WORKDIR /source/
COPY source/iis .
RUN dotnet restore; dotnet publish -c Release

# Middleware image used to extract ASP.NET core module
FROM microsoft/iis as WindowsBuild
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'Continue'; $verbosePreference='Continue';"]
# Installing NET CORE webhosting in middleware image so latest module and configuration schema is extracted for final image
ADD https://download.microsoft.com/download/B/1/D/B1D7D5BF-3920-47AA-94BD-7A6E48822F18/DotNetCore.2.0.0-WindowsHosting.exe ".\hosting.exe"
RUN start-process -Filepath .\hosting.exe -ArgumentList @('/install', '/quiet', '/norestart') -Wait 


FROM microsoft/iis:nanoserver
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'Continue'; $verbosePreference='Continue';"]
RUN start-process -Filepath dism.exe -ArgumentList  @('/online', '/enable-feature:IIS-WindowsAuthentication', '/ALL') -Wait  
# Adding NET CORE EXE to Path environment variable
RUN setx /M PATH $($Env:PATH + ';' + $Env:ProgramFiles + '\dotnet')
#Copy dotnet core installation from middleware image
COPY --from=CoreBuild ["c:\\Program Files\\dotnet", "c:\\program files\\dotnet"]
#Copy dotnet core module from middleware image
COPY --from=WindowsBuild ["c:\\Windows\\System32\\inetsrv\\aspnetcore.dll", "c:\\Windows\\System32\\inetsrv\\"]
COPY --from=WindowsBuild ["c:\\Windows\\System32\\inetsrv\\config\\schema\\aspnetcore_schema.xml",  "c:\\Windows\\System32\\inetsrv\\config\\schema\\"]
WORKDIR app
# Configure IIS to use ASPNET core module
RUN Import-Module IISAdministration; `
    Start-IISCommitDelay; `
    (Get-IISServerManager).GetApplicationHostConfiguration().RootSectionGroup.Sections.Add('appSettings') ; `
    (Get-IISServerManager).GetApplicationHostConfiguration().GetSection('system.webServer/handlers').Overridemode = 'Allow' ; `
    (Get-IISServerManager).GetApplicationHostConfiguration().RootSectionGroup.SectionGroups['system.webServer'].Sections.Add('aspNetCore'); `
    (Get-IISServerManager).GetApplicationHostConfiguration().RootSectionGroup.SectionGroups['system.webServer'].Sections['aspNetCore'].OverrideModeDefault = 'Allow'; `
    New-IISConfigCollectionElement (Get-IISConfigSection 'system.webServer/globalModules' | Get-IISConfigCollection) -ConfigAttribute @{'name'='AspNetCoreModule';'image'='C:\windows\system32\inetsrv\aspnetcore.dll'}; `
    New-IISConfigCollectionElement (Get-IISConfigSection 'system.webServer/modules' | Get-IISConfigCollection) -ConfigAttribute @{'name'='AspNetCoreModule'}; `
    Stop-IISCommitDelay
# Add local user for testing authentication against local SAM database
RUN  new-LocalUser -Name "ContainerAdmin" -Password  (ConvertTo-SecureString  "A123456!" -AsPlainText -Force); `
     Add-LocalGroupMember -Group Administrators -Member "ContainerAdmin" ; 
# Dot net core Application to show logged on user
RUN Import-Module IISAdministration; Start-IISCommitDelay; (Get-IISServerManager).ApplicationPools['DefaultAppPool'].ProcessModel.IdentityType='LocalSystem'; `
    (Get-IISServerManager).Sites[0].Applications[0].VirtualDirectories[0].PhysicalPath = 'c:\app'; (Get-IISConfigSection -SectionPath 'system.webServer/security/authentication/windowsAuthentication').Attributes['enabled'].value = $true; `
    Stop-IISCommitDelay
# Copying compiled file from middleware NET CORE builder SDK image 
COPY --from=builder /source/bin/Release/netcoreapp2.0/publish .
EXPOSE 80



