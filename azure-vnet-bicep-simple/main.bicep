@description('Name of the application.')
param applicationName string = uniqueString(resourceGroup().id)

@description('Name of the virtual network')
param vnetName string = '${applicationName}vnet'

@description('Location that the virtual network will be deployed to. Default is location of the resource group.')
param location string = resourceGroup().location

@description('Name of the App Subnet')
param subnetName string = 'AppSubnet'

resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' = {
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
        name: subnetName
        properties: {
          addressPrefix: '10.0.0.0/24'
        }
      }
    ]
  }
}
