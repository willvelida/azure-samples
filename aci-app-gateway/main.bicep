@description('Name of the application.')
param applicationName string = uniqueString(resourceGroup().id)

@description('Location of the APIM instance')
param location string = resourceGroup().location

@description('Name of the virtual network')
param vnetName string = 'vnet-${applicationName}'

@description('Name for the container group')
param aciGroupName string = 'aci${applicationName}'

@description('Name for the Application Gateway')
param appGatewayName string = 'appgw${applicationName}'

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

resource vnet 'Microsoft.Network/virtualNetworks@2022-01-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'myAGSubnet'
        properties: {
          addressPrefix: '10.0.1.0/24'
        }
      }
      {
        name: 'myACISubnet'
        properties: {
          addressPrefix: '10.0.2.0/24'
          delegations: [
            {
              name: 'delegation'
              properties: {
                serviceName: 'Microsoft.ContainerInstance/containerGroups'
              }
            }
          ]
        }
      }
    ]
  }
}

resource publicIp 'Microsoft.Network/publicIPAddresses@2022-01-01' = {
  name: 'publicIp-${applicationName}'
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource containerGroup 'Microsoft.ContainerInstance/containerGroups@2021-09-01' = {
  name: aciGroupName
  location: location
  properties: {
    containers: [
      {
        name: aciGroupName
        properties: {
          environmentVariables: [
            {
              name: 'ACI_IP'
              value: publicIp.properties.ipAddress
            }
          ]
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
      type: 'Private'
      ports: [
        {
          port: port
          protocol: 'TCP'
        }
      ]
    }
    subnetIds: [
      {
        id: vnet.properties.subnets[1].id
        name: vnet.properties.subnets[1].name
      }
    ]
  }
}

resource appGateway 'Microsoft.Network/applicationGateways@2022-01-01' = {
  name: appGatewayName
  location: location
  properties: {
    sku: {
      capacity: 2
      name: 'Standard_v2'
      tier: 'Standard_v2'
    }
    frontendIPConfigurations: [
      {
        properties: {
          publicIPAddress: {
            id: publicIp.id
          }
        }
      }
    ]
    httpListeners: [
      {
        properties: {
          protocol: 'Http'
        }
      }
    ]
  }
}
