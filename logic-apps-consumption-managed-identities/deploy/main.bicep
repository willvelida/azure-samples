param location string = resourceGroup().location

param applicationName string = uniqueString(resourceGroup().id)

var logicAppName = 'logicapp-${applicationName}'

resource logicApp 'Microsoft.Logic/workflows@2019-05-01' = {
  name: logicAppName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    accessControl: {
      triggers: {
        
      }
    }
  }
}
