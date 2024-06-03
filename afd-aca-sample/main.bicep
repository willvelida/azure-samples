@description('The suffix applied to all resources')
param appSuffix string = uniqueString(resourceGroup().id)

@description('The location to deploy all these resources to')
param location string = resourceGroup().location

@description('The tags to apply to all resources')
param tags object = {
  SampleName: 'aca-afd-waf'
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

param privateLinkServiceName string = 'pls-${appSuffix}'
param frontDoorName string = 'afd-${appSuffix}'
param originName string = 'origin-${appSuffix}'
param originGroupName string = 'origin-group-${appSuffix}'
param afdEndpointName string = 'afd-${appSuffix}'
param wafPolicyName string = 'wafpolicy${appSuffix}'
param securityPolicyName string = 'default-security-policy-${appSuffix}'

module vnet 'network/virtual-network.bicep' = {
  name: 'vnet'
  params: {
    location: location 
    tags: tags
    vnetName: virtualNetworkName
  }
}

module law 'monitor/log-analytics.bicep' = {
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

module pls 'network/private-link-service.bicep' = {
  name: 'pls'
  params: {
    defaultDomain: env.outputs.domain
    location: location
    name: privateLinkServiceName
    subnetId: vnet.outputs.privateLinkSubnetId
  }
}

module frontDoor 'network/azure-front-door.bicep' = {
  name: 'afd'
  params: {
    afdEndpointName: afdEndpointName
    fqdn: containerApp.outputs.fqdn
    location: location
    name: frontDoorName
    originGroupName: originGroupName
    originName: originName
    privateLinkId: pls.outputs.id
    afdSecurityPolicyName: securityPolicyName
    wafPolicyName: wafPolicyName
  }
}
