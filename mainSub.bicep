targetScope = 'subscription'

param rglocation string = 'canada central'
param resourceLocation string = 'canada central'

//storage account module parameters
param storageRGName string
param stgName string
param stgKind string
param stgSku string

//LAW Module parameters
param analyticsRGName string
param LAWName string
@maxValue(365)
param retentionInDays int

//VNet Module Parameters
param networkRGName string

param vNetName string
param subnet1Name string = 'default'
param subnet2Name string = 'PEP-Subnet'

//ADX Module Parameters
param adxRGName string

@allowed([
  'leader'
  'follower'
])
param leaderOrFollower string


@description('Enter a globally unique name for the ADX cluster')
@maxLength(22)
@minLength(5)
param clusterName string

@allowed([
  'Standard_L8as_v3' //Storage Optimized -- Leader Cluster
  'Standard_E8ads_v5' //Compute Optimized -- Follower Cluster
])
param clusterSKU string 

param optimizedAutoscale bool
param maxInstance int
@minValue(2)
param minInstance int

@allowed([
  'Basic'
  'Standard'
])
param clusterTier string = 'Standard'

//ADX Cluster Properties Parameters
param enableStreamingIngest bool
param enablePurge bool
param enableAutoStop bool
param enableDiskEncryption bool
param enableDoubleEncryption bool
param publicNetworkAccess string

@allowed([
  'SystemAssigned'
  'UserAssigned' 
  'SystemAssigned, UserAssigned'
  'None'
])
param clusterIdentity string

//Cluster Database Parameters
param databaseName string

@allowed([
  'ReadWrite'
  'ReadOnlyFollowing'
])
param dbKind string

// Diagnostic Settings Parameter
param diagnostsicSettingName string 

@description('Full ARM resource ID')
var LAWorkspace_RID = lawModule.outputs.resourceID
var storageAccount_MPE_RID = stgModule.outputs.resourceID


//Resources
//Resource Groups:
resource storageRG 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: storageRGName
  location: rglocation
}

resource analyticsRG 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: analyticsRGName
  location: rglocation
}

resource adxRG 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: adxRGName
  location: rglocation
}

resource networkRG 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: networkRGName
  location: rglocation
}

//Resource Modules:
//storage account
module stgModule 'modules/stgAccModule.bicep' = {
  // scope: resourceGroup(rg01.name)
  // or 
  // scope: resourceGroup(<subscriptionID>, <rgName>)
  // scope: resourceGroup('mytestrg')
  scope: storageRG //symbolic name
  name: 'stgModule'
  params: {
    stgName: stgName
    stgLocation: resourceLocation
    stgKind: stgKind
    stgSku: stgSku
  }
}

//log analytics workspace
module lawModule 'modules/LAWModule.bicep' = {
  scope: analyticsRG
  name: 'lawModule'
  params: {
    lawName: LAWName
    lawLocation: resourceLocation
    retentionInDays: retentionInDays
  }
}

//virtual networl
module vNetModule 'modules/vnetModule.bicep' = {
  scope: networkRG
  name: 'vNetModule'
  params:{
    vNetLocation: resourceLocation
    vNetName: vNetName
    subnet1Name: subnet1Name
    subnet2Name: subnet2Name
  }
}


//ADX Cluster
module adxModule 'modules/adxClusterModule.bicep' = {
  scope: adxRG
  name: clusterName
  params: {
    adxLocation: resourceLocation
    clusterIdentity: clusterIdentity
    clusterName: clusterName
    clusterSKU: clusterSKU
    clusterTier: clusterTier
    databaseName: databaseName
    dbKind: dbKind
    diagnostsicSettingName: diagnostsicSettingName
    enableAutoStop: enableAutoStop
    enableDiskEncryption: enableDiskEncryption
    enableDoubleEncryption: enableDoubleEncryption
    enablePurge: enablePurge
    enableStreamingIngest: enableStreamingIngest
    LAWorkspace_RID: LAWorkspace_RID
    leaderOrFollower: leaderOrFollower
    maxInstance: maxInstance
    minInstance: minInstance
    optimizedAutoscale: optimizedAutoscale
    publicNetworkAccess: publicNetworkAccess
    storageAccount_MPE_RID: storageAccount_MPE_RID
  }
}
