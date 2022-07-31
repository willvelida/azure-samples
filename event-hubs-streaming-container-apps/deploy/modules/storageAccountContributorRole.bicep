@description('The name of the storage account')
param storageAccountName string

@description('The Id of the Container App.')
param containerAppId string

@description('The Principal Id of the Container App')
param containerAppPrincipalId string

var storageAccountContributorRoleId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions','ba92f5b4-2d11-453d-a403-e96b0029c9fe')

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' existing =  {
  name: storageAccountName
}

resource storageAccountContributorRole 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
  name: guid(storageAccount.id, containerAppId, storageAccountContributorRoleId)
  properties: {
    principalId: containerAppPrincipalId
    roleDefinitionId: storageAccountContributorRoleId
    principalType: 'ServicePrincipal' 
  }
}
