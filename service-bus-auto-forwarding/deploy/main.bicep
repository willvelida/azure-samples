@description('The location to deploy our application to. Default is location of resource group')
param location string = resourceGroup().location

@description('Name of our application.')
param applicationName string = uniqueString(resourceGroup().id)

var serviceBusNamespace = '${applicationName}sb'
var ordersQueueName = 'ordersqueue'
var ordersTopicName = 'orderstopic'
var ordersSubscriptionName = 'orderssubscription'

resource serviceBus 'Microsoft.ServiceBus/namespaces@2022-01-01-preview' = {
  name: serviceBusNamespace
  location: location
  sku: {
    name: 'Standard'
  }
  identity: {
    type: 'SystemAssigned'
  }
}

resource ordersTopic 'Microsoft.ServiceBus/namespaces/topics@2022-01-01-preview' = {
  name: ordersTopicName
  parent: serviceBus
}

resource ordersSubscription 'Microsoft.ServiceBus/namespaces/topics/subscriptions@2022-01-01-preview' = {
  name: ordersSubscriptionName
  parent: ordersTopic
}

resource ordersQueue 'Microsoft.ServiceBus/namespaces/queues@2022-01-01-preview' = {
  name: ordersQueueName
  parent: serviceBus
  properties: {
    forwardTo: ordersTopic.name
  }
}
