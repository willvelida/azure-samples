@description('Name of the application.')
param applicationName string = uniqueString(resourceGroup().id)

@description('Location of the APIM instance')
param location string = resourceGroup().location

@description('Name of the APIM instance')
param apimInstanceName string = 'apim${applicationName}'

@description('Email of the APIM publisher')
param publisherEmail string

@description('Name of the publisher for APIM')
param publisherName string

@description('Name for the container group')
param aciGroupName string = 'aci${applicationName}'

@description('Container image to deploy. Should be of the form repoName/imagename:tag for images stored in public Docker Hub, or a fully qualified URI for other registries. Images from private registries require additional registry credentials.')
param image string = 'willvelida/simpleweatherapi'

@description('Port to open on the container and the public IP address.')
param port int = 80

@description('The number of CPU cores to allocate to the container.')
param cpuCores int = 1

@description('The amount of memory to allocate to the container in gigabytes.')
param memoryInGb int = 2

@description('The behavior of Azure runtime if container has stopped.')
@allowed([
  'Always'
  'Never'
  'OnFailure'
])
param restartPolicy string = 'Always'

resource containerGroup 'Microsoft.ContainerInstance/containerGroups@2021-09-01' = {
  name: aciGroupName
  location: location
  properties: {
    containers: [
      {
        name: aciGroupName
        properties: {
          image: image
          ports: [
            {
              port: port
              protocol: 'TCP'
            }
          ]
          resources: {
            requests: {
              cpu: cpuCores
              memoryInGB: memoryInGb
            }
          }
        }
      }
    ]
    osType: 'Linux'
    restartPolicy: restartPolicy
    ipAddress: {
      dnsNameLabel: aciGroupName
      type: 'Public'
      ports: [
        {
          port: port
          protocol: 'TCP'
        }
      ]
    }
  }
}

resource apim 'Microsoft.ApiManagement/service@2021-08-01' = {
  name: apimInstanceName
  location: location
  sku: {
    capacity: 1
    name: 'Developer'
  }
  properties: {
    publisherEmail: publisherEmail
    publisherName: publisherName
  }
}

resource weatherApi 'Microsoft.ApiManagement/service/apis@2021-12-01-preview' = {
  name: 'WeatherAPI'
  parent: apim
  properties: {
    displayName: 'Weather API'
    path: 'Weather'
    serviceUrl: 'http://${containerGroup.properties.ipAddress.fqdn}'
    protocols: [
      'HTTPS'
    ]
  }
}

resource getWeather 'Microsoft.ApiManagement/service/apis/operations@2021-12-01-preview' = {
  name: 'GetWeather'
  parent: weatherApi
  properties: {
    displayName: 'GET weather'
    method: 'GET'
    urlTemplate: '/WeatherForecast' 
  }
}
