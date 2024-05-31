@description('The name given to the Log Analytics workspace')
param logAnalyticsWorkspaceName string

@description('The location to where the Log Analytics workspace will be deployed')
param location string

@description('The tags that will be applied to the Log Analytics workspace')
param tags object

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: logAnalyticsWorkspaceName
  location: location
  tags:tags
  properties: {
    retentionInDays: 30
    features: {
      searchVersion: 1
    }
    sku: {
      name: 'PerGB2018'
    }
  }
}

@description('The name of the Log Analytics Workspace')
output name string = logAnalytics.name
