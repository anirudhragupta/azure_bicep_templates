targetScope = 'subscription'

param rglocation string
param resourceLocation string

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
param defaultSubnetName string 
param pepSubnetName string

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
  'Dev(No SLA)_Standard_D11_v2' //Dev
])
param clusterSKU string 

@allowed([
  'Basic'
  'Standard'
])
param clusterTier string

param optimizedAutoscale bool
param maxInstance int
@minValue(2)
param minInstance int


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

//ADX Managed PE
param adxMPEName string 
var storageAccount_MPE_RID = stgModule.outputs.resourceID

//Private Endpoints parameters
param adxPEName string
param dnsGroupName string

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

//virtual network
module vNetModule 'modules/vnetModule.bicep' = {
  scope: networkRG
  name: 'vNetModule'
  params:{
    vNetLocation: resourceLocation
    vNetName: vNetName
    defaultSubnetName: defaultSubnetName
    pepSubnetName: pepSubnetName
  }
}


//ADX Cluster
module adxModule 'modules/adxClusterModule.bicep' = {
  scope: adxRG
  name: clusterName
  params: {
    leaderOrFollower: leaderOrFollower
    //cluster resource
    adxLocation: resourceLocation
    clusterName: clusterName
    clusterSKU: clusterSKU
    clusterTier: clusterTier
    //cluster database
    databaseName: databaseName
    dbKind: dbKind
    //cluster configuration
    clusterIdentity: clusterIdentity
    enableAutoStop: enableAutoStop
    enableDiskEncryption: enableDiskEncryption
    enableDoubleEncryption: enableDoubleEncryption
    enablePurge: enablePurge
    enableStreamingIngest: enableStreamingIngest
    publicNetworkAccess: publicNetworkAccess
    optimizedAutoscale: optimizedAutoscale
    maxInstance: maxInstance
    minInstance: minInstance
    //diagnostic settings
    diagnostsicSettingName: diagnostsicSettingName
    LAWorkspace_RID: LAWorkspace_RID
    //managed private endpoints
    adxMPEName: adxMPEName
    storageAccount_MPE_RID: storageAccount_MPE_RID
    //Private endpoint and private DNS
    adxPEName:adxPEName
    vnet_RID: vNetModule.outputs.vnet_RID
    subnet_RID: vNetModule.outputs.subnet_RID
    dnsGroupName: dnsGroupName
  }
}
