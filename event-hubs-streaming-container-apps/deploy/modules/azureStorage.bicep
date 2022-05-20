@description('The name of the storage account')
param storageAccountName string

@description('The location of the storage account')
param location string

@description('The SKU of the storage account')
param storageAccountSku string

@description('The name of the container for this storage account')
param storageContainerName string

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageAccountSku
  }
  kind: 'StorageV2'
  identity: {
    type: 'SystemAssigned'
  }
}

resource blobServices 'Microsoft.Storage/storageAccounts/blobServices@2021-09-01' = {
  name: 'default'
  parent: storageAccount
}

resource container 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-09-01' = {
  name: storageContainerName
  parent: blobServices
}
