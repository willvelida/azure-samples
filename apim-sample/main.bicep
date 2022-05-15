@description('Name of the APIM instance')
param apimInstanceName string = 'velidaapim'

@description('Location of the APIM instance')
param location string = resourceGroup().location

@description('Email of the APIM publisher')
param publisherEmail string = 'willvelida@hotmail.co.uk'

@description('Name of the publisher for APIM')
param publisherName string = 'Will Velida Org'

resource apim 'Microsoft.ApiManagement/service@2021-08-01' = {
  name: apimInstanceName
  location: location
  sku: {
    capacity: 1
    name: 'Developer'
  }
  properties: {
    publisherEmail: publisherEmail
    publisherName: publisherName
  }
}
