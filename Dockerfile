FROM mcr.microsoft.com/dotnet/sdk:6.0 AS builder
WORKDIR /Application/src/RazorPagesTestSample

# caches restore result by copying csproj file separately
COPY *.csproj .
RUN dotnet restore

COPY . .
RUN dotnet publish --output /Application/src/RazorPagesTestSample/ --configuration Release --no-restore
RUN sed -n 's:.*<AssemblyName>\(.*\)</AssemblyName>.*:\1:p' *.csproj > __assemblyname
RUN if [ ! -s __assemblyname ]; then filename=$(ls *.csproj); echo ${filename%.*} > __assemblyname; fi

# Stage 2
FROM mcr.microsoft.com/dotnet/aspnet:6.0
WORKDIR /Application/src/RazorPagesTestSample
COPY --from=builder /Application/src/RazorPagesTestSample .

ENV PORT 5000
EXPOSE 5000

ENTRYPOINT dotnet $(cat /Application/src/RazorPagesTestSample/__assemblyname).dll --urls "http://*:5000"
