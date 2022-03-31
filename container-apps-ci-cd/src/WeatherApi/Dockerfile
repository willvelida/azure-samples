FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /app 
EXPOSE 80

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src
COPY ["WeatherApi/WeatherApi.csproj" "WeatherApi/"]

RUN dotnet restore "WeatherApi/WeatherApi.csproj"
COPY . .
WORKDIR "/src/WeatherApi"
RUN dotnet build "WeatherApi.csproj" -c Release -o /app

FROM build AS publish
RUN dotnet publish "WeatherApi.csproj" -c Release -o /app

FROM base AS final 
WORKDIR /app
COPY --from=publish /app .
ENTRYPOINT [ "dotnet", "WeatherApi.dll" ]