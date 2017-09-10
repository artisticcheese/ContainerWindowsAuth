# escape=`

# Image with SDK to build .NET Core application from source
FROM microsoft/aspnetcore-build:2.0.0-nanoserver As builder
WORKDIR /source/
COPY source .
RUN dotnet restore; dotnet publish -c Release

FROM microsoft/aspnetcore:2.0.0-nanoserver
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'Continue'; $verbosePreference='Continue';"]
#Copy dotnet core installation from middleware image
WORKDIR app
# Add local user for testing authentication against local SAM database
RUN  new-LocalUser -Name "ContainerAdmin" -Password  (ConvertTo-SecureString  "A123456!" -AsPlainText -Force); `
     Add-LocalGroupMember -Group Administrators -Member "ContainerAdmin" ; 
# Copying compiled file from middleware NET CORE builder SDK image 
COPY --from=builder /source/bin/Release/netcoreapp2.0/publish .
EXPOSE 80
ENTRYPOINT ["Dotnet", "source.dll"]