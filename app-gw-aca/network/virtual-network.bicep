@description('The name of the virtual network')
param vnetName string

@description('Location of the Vnet')
param location string

@description('The tags that will be applied to the VNet')
param tags object

var envInfraSubnetName = 'infra-subnet'
var appGatewaySubnetName = 'app-gateway-subnet'

resource vnet 'Microsoft.Network/virtualNetworks@2023-11-01' = {
  name: vnetName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      { 
        name: envInfraSubnetName
        properties: {
          addressPrefix: '10.0.0.0/23'
        }
      }
      { 
        name: appGatewaySubnetName
        properties: {
          addressPrefix: '10.0.2.0/24'
          privateLinkServiceNetworkPolicies: 'Disabled'
        }
      }
    ]
  }

  resource envSubnet 'subnets' existing = {
    name: envInfraSubnetName
  }

  resource appGatewaySubnet 'subnets' existing = {
    name: appGatewaySubnetName
  }
}

output name string = vnet.name
output acaSubnetId string = vnet::envSubnet.id
output appGatewaySubnetId string = vnet::appGatewaySubnet.id
