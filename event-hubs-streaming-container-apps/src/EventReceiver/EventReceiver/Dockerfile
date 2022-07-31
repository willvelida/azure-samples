FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build-env
WORKDIR /EventReceiver

COPY . ./
RUN dotnet restore
RUN dotnet publish -c Release -o out

FROM mcr.microsoft.com/dotnet/runtime:6.0
WORKDIR /EventReceiver
COPY --from=build-env /EventReceiver/out .
ENTRYPOINT ["dotnet", "EventReceiver.dll"]