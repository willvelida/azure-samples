param envStaticIp string
param envDefaultDomain string
param tags object
param vnetName string

resource vnet 'Microsoft.Network/virtualNetworks@2023-11-01' existing = {
  name: vnetName
}

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: envDefaultDomain
  location: 'global'
  tags: tags
}

resource starRecordSet 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  name: '*'
  parent: privateDnsZone
  properties: {
    ttl: 3600
    aRecords: [
      { 
        ipv4Address: envStaticIp
      }
    ]
  }
}

resource atRecordSet 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  name: '@'
  parent: privateDnsZone
  properties: {
    ttl: 3600
    aRecords: [
      { 
        ipv4Address: envStaticIp
      }
    ]
  }
}

resource privateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${vnet.name}-pdns-link'
  parent: privateDnsZone
  tags: tags
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnet.id
    }
  }
}
