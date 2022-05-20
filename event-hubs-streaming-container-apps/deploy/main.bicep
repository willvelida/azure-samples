@description('The location where we will deploy our resources to. Default is the location of the resource group')
param location string = resourceGroup().location

@description('Name of our application.')
param applicationName string = uniqueString(resourceGroup().id)

var logAnalyticsWorkspaceName = '${applicationName}la'
var containerRegistryName = '${applicationName}acr'
var containerRegistrySku = 'Basic'
var containerAppEnvironmentName = '${applicationName}env'
var senderAppName = 'sender-app'
var receiverAppName = 'receiver-app'
var cosmosDbAccountName = '${applicationName}db'
var databaseName = 'ReadingsDb'
var containerName = 'Readings'
var containerThroughput = 400
var eventHubsName = '${applicationName}eh'
var eventHubsSkuName = 'Standard'
var consumerGroupName = 'receiverconsumergroup'
var hubName = 'readings'
var storageAccountName = 'fnstor${replace(applicationName, '-', '')}'
var storageContainerName = 'checkpoints'
var storageSkuName = 'Standard_LRS'

module cosmosDb 'modules/cosmosDb.bicep' = {
  name: 'cosmosDb'
  params: {
    containerName: containerName
    containerThroughput: containerThroughput
    cosmosDbAccountName: cosmosDbAccountName
    databaseName: databaseName
    location: location
  }
}

module eventHub 'modules/eventHubs.bicep' = {
  name: 'eventhub'
  params: {
    eventHubsName: eventHubsName
    eventHubsSkuName: eventHubsSkuName
    hubName: hubName
    location: location
    consumerGroupName: consumerGroupName
  }
}

module eventHubSendRole 'modules/eventHubDataSenderRoleAssignment.bicep' = {
  name: 'sendrole'
  params: {
    containerAppId: senderApp.id 
    containerAppPrincipalId: senderApp.identity.principalId
    eventHubNamespaceName: eventHub.outputs.eventHubNamespaceName
  }
}

module eventHubReceiveRole 'modules/eventHubDataReceiverRoleAssignment.bicep' = {
  name: 'receiverole'
  params: {
    containerAppId: receiverApp.id
    containerAppPrincipalId: receiverApp.identity.principalId
    eventHubNamespaceName: eventHub.outputs.eventHubNamespaceName
  }
}

module storageAccount 'modules/azureStorage.bicep' = {
  name: 'storageAccount'
  params: {
    location: location
    storageAccountName: storageAccountName 
    storageAccountSku: storageSkuName
    storageContainerName: storageContainerName
  }
}

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' = {
  name: logAnalyticsWorkspaceName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    } 
  }
}

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2021-12-01-preview' = {
  name: containerRegistryName
  location: location
  sku: {
    name: containerRegistrySku
  }
  properties: {
    adminUserEnabled: true
  }
  identity: {
    type: 'SystemAssigned'
  }
}

resource containerAppEnvironment 'Microsoft.App/managedEnvironments@2022-03-01' = {
  name: containerAppEnvironmentName
  location: location
  properties: {
   appLogsConfiguration: {
     destination: 'log-analytics'
     logAnalyticsConfiguration: {
       customerId: logAnalytics.properties.customerId
       sharedKey: logAnalytics.listKeys().primarySharedKey
     }
   } 
  }
}

resource senderApp 'Microsoft.App/containerApps@2022-03-01' = {
  name: senderAppName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    managedEnvironmentId: containerAppEnvironment.id
    configuration: {
      activeRevisionsMode: 'multiple'
      ingress: {
        external: true
        targetPort: 80
        allowInsecure: false
        traffic: [
          {
            latestRevision: true
            weight: 100
          }
        ]
      }
      secrets: [
        {
          name: 'registrypassword'
          value: containerRegistry.listCredentials().passwords[0].value
        }
        {
          name: 'eventhubconnection'
          value: '${eventHub.outputs.eventHubNamespaceName}.servicebus.windows.net'
        }
        {
          name: 'readingseventhub'
          value: eventHub.outputs.eventHubName
        }
      ]
      registries: [
        {
          username: containerRegistry.listCredentials().username
          server: '${containerRegistry.name}.azurecr.io'
          passwordSecretRef: 'registrypassword'
        }
      ]
    }
    template: {
      containers: [
        {
          name: senderAppName
          image: 'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest'
          resources: {
            cpu: '0.5'
            memory: '1Gi'
          }
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 10
      }
    } 
  }
}

resource receiverApp 'Microsoft.App/containerApps@2022-03-01' = {
  name: receiverAppName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    managedEnvironmentId: containerAppEnvironment.id
    configuration: {
      activeRevisionsMode: 'multiple'
      ingress: {
        external: false
        targetPort: 443
        allowInsecure: false
        traffic: [
          {
            latestRevision: true
            weight: 100
          }
        ]
      }
      secrets: [
        {
          name: 'registrypassword'
          value: containerRegistry.listCredentials().passwords[0].value
        }
        {
          name: 'eventhubconnection'
          value: '${eventHub.outputs.eventHubNamespaceName}.servicebus.windows.net'
        }
        {
          name: 'readingseventhub'
          value: eventHub.outputs.eventHubName
        }
        {
          name: 'cosmosdbendpoint'
          value: cosmosDb.outputs.cosmosDbEndpoint
        }
        {
          name: 'databasename'
          value: cosmosDb.outputs.databaseName
        }
        {
          name: 'containername'
          value: cosmosDb.outputs.containerName
        }
        {
          name: 'consumergroupname'
          value: eventHub.outputs.consumerGroupName
        }
      ]
      registries: [
        {
          username: containerRegistry.listCredentials().username
          server: '${containerRegistry.name}.azurecr.io'
          passwordSecretRef: 'registrypassword'
        }
      ]
    }
    template: {
      containers: [
        {
          name: receiverAppName
          image: 'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest'
          resources: {
            cpu: '0.5'
            memory: '1Gi'
          }
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 10
      }
    } 
  }
}
