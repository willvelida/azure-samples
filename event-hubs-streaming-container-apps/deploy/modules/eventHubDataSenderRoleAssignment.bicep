@description('The Name of the Event Hubs Namepace')
param eventHubNamespaceName string

@description('The Id of the Container App')
param containerAppId string

@description('The Principal Id of the Container App')
param containerAppPrincipalId string

var eventHubsDataSenderRoleId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'a638d3c7-ab3a-418d-83e6-5f17a39d4fde')

resource eventHub 'Microsoft.EventHub/namespaces@2021-11-01' existing = {
  name: eventHubNamespaceName
}

resource eventHubsDataSenderRole 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
  name: guid(eventHub.id, containerAppId, eventHubsDataSenderRoleId)
  scope: eventHub
  properties: {
    principalId: containerAppPrincipalId
    roleDefinitionId: eventHubsDataSenderRoleId
    principalType: 'ServicePrincipal'
  }
}
