@description('Name of the application.')
param applicationName string = uniqueString(resourceGroup().id)

@description('Location that the AKS cluster will be deployed to. Default is location of resource group.')
param location string = resourceGroup().location

@description('The name of the AKS Cluster')
param aksClusterName string = '${applicationName}aks'

@description('The VM size of the Agents')
param agentVMSize string = 'Standard_D2s_v3'

@description('Disk size to provision for each of the agent pool nodes.')
param osDiskSizeGB int = 0

@description('The number of the nodes for the cluster. Default is 1')
param agentCount int = 3

resource aksCluster 'Microsoft.ContainerService/managedClusters@2022-01-02-preview' = {
  name: aksClusterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    enableRBAC: true
    dnsPrefix: '${applicationName}aks'
    agentPoolProfiles: [
      {
        name: 'agentpool'
        osDiskSizeGB: osDiskSizeGB
        count: agentCount
        vmSize: agentVMSize
        osType: 'Linux'
        type: 'VirtualMachineScaleSets'
        mode: 'System'
      }
    ]
  }
}
