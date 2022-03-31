@description('The location where we will deploy our resources to. Default is the location of the resource group')
param location string = resourceGroup().location

@description('Namoe of our application.')
param applicationName string = uniqueString(resourceGroup().id)

@description('The image that we will deploy to our Container App')
param containerImage string = 'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest'

@description('Username for the Azure Container Registry.')
param acrUsername string

@description('Password for the Azure Container Registry')
@secure()
param acrPassword string

var logAnalyticsName = '${applicationName}la'
var registryName = '${applicationName}cr'
var containerEnvName = '${applicationName}enc'
var containerAppName = 'weatherapi'

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' = {
  name: logAnalyticsName
  location: location 
  properties: {
    sku: {
      name: 'PerGB2018'
    }
  }
}

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2021-12-01-preview' = {
  name: registryName
  location: location 
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: true
  }
}

resource containerEnvironment 'Microsoft.App/managedEnvironments@2022-01-01-preview' = {
  name: containerEnvName
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

resource dotnetApp 'Microsoft.App/containerApps@2022-01-01-preview' = {
  name: containerAppName
  location: location
  properties: {
    managedEnvironmentId: containerEnvironment.id
    configuration: {
      secrets: [
        {
          name: 'registrypassword'
          value: acrPassword
        }
      ]
      registries: [
        {
          server: '${containerRegistry.name}.azurecr.io'
          username: acrUsername
          passwordSecretRef: 'registrypassword'
        }
      ]
      ingress: {
        external: true
        targetPort: 80
        allowInsecure: false
      }
    }
    template: {
      containers: [
        {
          image: containerImage
          name: 'weatherapi'
          resources: {
            cpu: '0.5'
            memory: '1.0Gi'
          }
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 1
      }
    }
  }
}
