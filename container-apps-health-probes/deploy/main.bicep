@description('The region where we will deploy our resources to. Default is the location of the resource group')
param location string = resourceGroup().location

@description('The name of our application')
param applicationName string = uniqueString(resourceGroup().id)

var logAnalyticsName = '${applicationName}la'
var containerEnvName = '${applicationName}env'
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

resource containerEnv 'Microsoft.App/managedEnvironments@2022-01-01-preview' = {
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

resource containerApp 'Microsoft.App/containerApps@2022-01-01-preview' = {
  name: containerAppName
  location: location
  properties: {
    managedEnvironmentId: containerEnv.id
    configuration: {
      ingress: {
        external: true
        targetPort: 80
        allowInsecure: false
      }
    }
    template: {
      containers: [
        {
          image: 'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest'
          name: 'web'
          probes: [
            {
              type: 'liveness'
              httpGet: {
                path: '/health'
                port: 8080
                httpHeaders: [
                  {
                    name: 'Custom-Header'
                    value: 'liveness probe'
                  }
                ]
              }
              initialDelaySeconds: 7
              periodSeconds: 3
            }
            {
              type: 'readiness'
              tcpSocket: {
                port: 8081
              }
              initialDelaySeconds: 10
              periodSeconds: 3
            }
            {
              type: 'startup'
              httpGet: {
                path: '/startup'
                port: 8080
                httpHeaders: [
                  {
                    name: 'Custom-Header'
                    value: 'startup probe'
                  }
                ]
              }
              initialDelaySeconds: 3
              periodSeconds: 3
            }
          ]
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 3
      }
    }
  }
}
