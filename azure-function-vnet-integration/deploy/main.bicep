@description('Name of the application.')
param applicationName string = uniqueString(resourceGroup().id)

@description('Location to deploy the resources in this sample. Default is the location of the resource group')
param location string

@description('The Name of the App Service Plan to deploy.')
param appServicePlanName string = '${applicationName}asp'

@description('The name of the storage account that this Function will use')
param storageAccountName string = 'fnstor${replace(applicationName, '-', '')}'

@description('The name of the App Insights instance we will deploy.')
param appInsightsName string = '${applicationName}ai'

@description('The name of the virtual network that we will deploy.')
param vnetName string = '${applicationName}vnet'

resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'default'
        properties: {
          addressPrefix: '10.0.0.0/24'
        }
      }
      {
        name: 'functions'
        properties: {
         addressPrefix: '10.0.1.0/24' 
        }
      }
    ]
  }
}

resource appServicePlan 'Microsoft.Web/serverfarms@2021-03-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: 'EP1'
    tier: 'ElasticPremium'
  }
  kind: 'elastic'
  properties: {
    maximumElasticWorkerCount: 20
  }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-08-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}
