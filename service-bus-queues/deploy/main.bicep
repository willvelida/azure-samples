@description('The location where we will deploy our resources to. Default is the location of the resource group')
param location string = resourceGroup().location

@description('Namoe of our application.')
param applicationName string = uniqueString(resourceGroup().id)

var serviceBusName = '${applicationName}sb'
var queueName = 'messages'

resource serviceBusNamespace 'Microsoft.ServiceBus/namespaces@2021-11-01' = {
  name: serviceBusName
  location: location
  sku: {
    name: 'Basic'
  }
}

resource serviceBusQueue 'Microsoft.ServiceBus/namespaces/queues@2021-11-01' = {
  name: queueName
  parent: serviceBusNamespace
}
