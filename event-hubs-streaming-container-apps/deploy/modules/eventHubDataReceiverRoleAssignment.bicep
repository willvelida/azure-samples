@description('The Name of the Event Hubs Namepace')
param eventHubNamespaceName string

@description('The Id of the Container App')
param containerAppId string

@description('The Principal Id of the Container App')
param containerAppPrincipalId string

var eventHubsDataReceiverRoleId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '2b629674-e913-4c01-ae53-ef4638d8f975')

resource eventHub 'Microsoft.EventHub/namespaces@2021-11-01' existing = {
  name: eventHubNamespaceName
}

resource eventHubsDataReceiverRole 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
  scope: eventHub
  name: guid(eventHub.id, containerAppId, eventHubsDataReceiverRoleId)
  properties: {
    principalId: containerAppPrincipalId
    roleDefinitionId: eventHubsDataReceiverRoleId
    principalType: 'ServicePrincipal'
  }
}
