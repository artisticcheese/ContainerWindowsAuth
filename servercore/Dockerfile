# escape=`
FROM microsoft/iis
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'Continue'; $verbosePreference='Continue';"]
WORKDIR app
#Adding Windows Authentication Feature since not installed in default image
RUN Install-WindowsFeature "Web-Windows-Auth"
#Adding local user for testing local Windows Authentication
RUN  new-LocalUser -Name "ContainerAdmin" -Password  (ConvertTo-SecureString  "A123456!" -AsPlainText -Force); `
     Add-LocalGroupMember -Group Administrators -Member "ContainerAdmin" ; 
RUN Import-Module IISAdministration; `
    Start-IISCommitDelay; (Get-IISServerManager).ApplicationPools['DefaultAppPool'].ProcessModel.IdentityType='LocalSystem'; `
    #(Get-IISServerManager).Sites[0].Applications[0].VirtualDirectories[0].PhysicalPath = 'c:\app'; `
    (Get-IISConfigSection -SectionPath 'system.webServer/security/authentication/windowsAuthentication').Attributes['enabled'].value = $true; `
    (Get-IISConfigSection -SectionPath 'system.webServer/security/authentication/anonymousAuthentication').Attributes['enabled'].value = $false; `
    Stop-IISCommitDelay
EXPOSE 80

