@description('Name that will be used in the application.')
param applicationName string = uniqueString(resourceGroup().id)

@description('The location where we will deploy our Redis Cache. Default is location of resource group.')
param location string = resourceGroup().location

var cacheName = '${applicationName}rdc'

resource redisCache 'Microsoft.Cache/redis@2021-06-01' = {
  name: cacheName
  location: location
  properties: {
    sku: {
      capacity: 0
      family: 'C'
      name: 'Basic'
    }
  }
  identity: {
    type: 'SystemAssigned'
  }
}
