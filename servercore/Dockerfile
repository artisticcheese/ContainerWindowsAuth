# escape=`
FROM microsoft/iis
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'Continue'; $verbosePreference='Continue';"]
WORKDIR app
#Adding Windows Authentication Feature since not installed in default image
RUN Install-WindowsFeature "Web-Windows-Auth", "Web-Asp-Net45"
#Adding local user for testing local Windows Authentication
RUN  new-LocalUser -Name "ContainerAdmin" -Password  (ConvertTo-SecureString  "A123456!" -AsPlainText -Force); `
     Add-LocalGroupMember -Group Administrators -Member "ContainerAdmin" ; 
COPY ["default.aspx", "c:\\inetpub\\wwwroot\\app\\"]
RUN Import-Module IISAdministration; `
    Start-IISCommitDelay; `
    (Get-IISConfigSection -SectionPath 'system.webServer/security/authentication/windowsAuthentication').Attributes['enabled'].value = $true; `
    (Get-IISConfigSection -SectionPath 'system.webServer/security/authentication/anonymousAuthentication').Attributes['enabled'].value = $false; `
    (Get-IISServerManager).Sites[0].Applications[0].VirtualDirectories[0].PhysicalPath = 'c:\inetpub\wwwroot\app' ; `
    Stop-IISCommitDelay
EXPOSE 80

