@description('The name of the virtual network')
param vnetName string

@description('Location of the Vnet')
param location string

@description('The tags that will be applied to the VNet')
param tags object

var envInfraSubnetName = 'infra-subnet'
var privateLinkServiceSubnetName = 'privatelinkservice-subnet'

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
          delegations: [
            
          ]
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      { 
        name: privateLinkServiceSubnetName
        properties: {
          addressPrefix: '10.0.2.0/24'
          delegations: [
            
          ]
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Disabled'
        }
      }
    ]
  }

  resource envSubnet 'subnets' existing = {
    name: envInfraSubnetName
  }

  resource plsSubnet 'subnets' existing = {
    name: privateLinkServiceSubnetName
  }
}

output name string = vnet.name
output acaSubnetId string = vnet::envSubnet.id
output privateLinkSubnetId string = vnet::plsSubnet.id
