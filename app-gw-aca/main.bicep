@description('The suffix applied to all resources')
param appSuffix string = uniqueString(resourceGroup().id)

@description('The location to deploy all these resources to')
param location string = resourceGroup().location

@description('The tags to apply to all resources')
param tags object = {
  SampleName: 'aca-app-gateway'
  Owner: 'Will Velida'
  Application: 'Azure-Samples'
  Environment: 'DEV'
}

@description('The name of the container app env')
param envName string = 'env-${appSuffix}'

@description('The name of the Virtual Network that will be deployed')
param virtualNetworkName string = 'vnet-${appSuffix}'

@description('The name of the Log Analytics workspace that will be deployed')
param logAnalyticsName string = 'law-${appSuffix}'

@description('The name of the Container App that will be deployed')
param containerAppName string = 'app-${appSuffix}'

@description('The name of the App Gateway that will be deployed')
param appGatewayName string = 'gw-${appSuffix}'

@description('The name of the Public IP address that will be deployed')
param ipAddressName string = '${appGatewayName}-pip'

@description('The name of the Private Link Service that will be created')
param privateLinkServiceName string = 'my-agw-private-link'

module vnet 'network/virtual-network.bicep' = {
  name: 'vnet'
  params: {
    location: location 
    tags: tags
    vnetName: virtualNetworkName
  }
}

module law 'monitoring/log-analytics.bicep' = {
  name: 'law'
  params: {
    location: location 
    logAnalyticsWorkspaceName: logAnalyticsName
    tags: tags
  }
}

module env 'host/container-app-env.bicep' = {
  name: 'env'
  params: {
    acaSubnetId: vnet.outputs.acaSubnetId 
    envName: envName 
    lawName: law.outputs.name
    location: location
    tags: tags
  }
}

module containerApp 'host/container-app.bicep' = {
  name: 'app'
  params: {
    containerAppEnvName: env.outputs.containerAppEnvName
    containerAppName: containerAppName
    location: location
    tags: tags
  }
}

module privateDnsZone 'network/private-dns-zone.bicep' = {
  name: 'pdns'
  params: {
    envDefaultDomain: env.outputs.domain
    envStaticIp: env.outputs.staticIp
    tags: tags
    vnetName: vnet.outputs.name
  }
}

module appGateway 'network/app-gateway.bicep' = {
  name: 'appgateway'
  params: {
    appGatewayName: appGatewayName
    containerAppFqdn: containerApp.outputs.fqdn
    envSubnetId: vnet.outputs.acaSubnetId
    ipAddressName: ipAddressName
    location: location
    privateLinkServiceName: privateLinkServiceName
    subnetId: vnet.outputs.appGatewaySubnetId
    tags: tags
  }
}
