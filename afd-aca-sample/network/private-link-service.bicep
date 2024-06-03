param name string
param location string
param subnetId string
param defaultDomain string

var loadBalancerName = 'kubernetes-internal'
var defaultDomainArr = split(defaultDomain, '.')
var appEnvironmentResourceGroupName = 'mc_${defaultDomainArr[0]}-rg_${defaultDomainArr[0]}_${defaultDomainArr[1]}'

resource loadBalancer 'Microsoft.Network/loadBalancers@2023-11-01' existing = {
  name: loadBalancerName
  scope: resourceGroup(appEnvironmentResourceGroupName)
}

resource privateLinkService 'Microsoft.Network/privateLinkServices@2023-11-01' = {
  name: name
  location: location
  properties: {
    autoApproval: {
      subscriptions: [
        subscription().subscriptionId
      ]
    }
    visibility: {
      subscriptions: [
        subscription().subscriptionId
      ]
    }
    fqdns: [
      
    ]
    enableProxyProtocol: false
    loadBalancerFrontendIpConfigurations: [
      { 
        id: loadBalancer.properties.frontendIPConfigurations[0].id
      }
    ]
    ipConfigurations: [
      { 
        name: 'ipconfig-0'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnetId
          }
          primary: true 
          privateIPAddressVersion: 'IPv4'
        }
      }
    ]
  }
}

output id string = privateLinkService.id
output name string = privateLinkService.name
