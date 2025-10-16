# Build the application
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src

COPY src/Server/Server.csproj src/Server/
COPY src/Shared/Shared.csproj src/Shared/
RUN dotnet restore src/Server/Server.csproj

COPY . .

WORKDIR /src/src/Server
RUN dotnet build Server.csproj -c Release -o /app/build

# Publish
RUN dotnet publish Server.csproj -c Release -o /app/publish

# Runtime image
FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS runtime
WORKDIR /app

COPY --from=build /app/publish .

EXPOSE 80
EXPOSE 443

ENV ASPNETCORE_URLS=http://+:80
ENV ASPNETCORE_ENVIRONMENT=Production
ENV DOTNET_ENVIRONMENT=Production

# Run the application
ENTRYPOINT ["dotnet", "Server.dll"]