//Parameters:
//ADX Cluster Parameters
@allowed([
  'leader'
  'follower'
])
param leaderOrFollower string
var dbCreate = (leaderOrFollower == 'leader')

@allowed([
  'canada central'
])
param location string

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
param clusterTier string

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

@description('Full ARM resource ID of the Log Analytics workspace to which you would like to send Diagnostic Logs')
param LAWorkspaceID string

param storageAccounts_MPE_RID string

//Resources:
//ADX Cluster Resource
resource adxCluster 'Microsoft.Kusto/clusters@2022-12-29' = {
  name: clusterName
  location: location
  sku: {
    name: clusterSKU
    tier: clusterTier
  }
  identity:{
    type: clusterIdentity
  }
  properties:{
    enableStreamingIngest: enableStreamingIngest
    enablePurge: enablePurge
    enableAutoStop: enableAutoStop
    enableDiskEncryption: enableDiskEncryption
    enableDoubleEncryption: enableDoubleEncryption
    publicNetworkAccess: publicNetworkAccess
    optimizedAutoscale: {
      isEnabled: optimizedAutoscale
      maximum: maxInstance
      minimum: minInstance
      version: 1
    }
  }

  //ADX Database Resource
  resource database01 'databases@2022-12-29' = if (dbCreate)  {
    name: databaseName
    location: location
    kind: dbKind
  }
}


resource clusterLogsDiagnostic 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: diagnostsicSettingName
  scope: adxCluster
  properties: {
    logs:[
    {
      category: 'SucceededIngestion'
      categoryGroup: null
      enabled: true
    }
    {
      category: 'FailedIngestion'
      categoryGroup: null
      enabled: true
    }
    {
      category: 'IngestionBatching'
      categoryGroup: null
      enabled: true
    }
    {
      category: 'Command'
      categoryGroup: null
      enabled: true
    }
    {
      category: 'Query'
      categoryGroup: null
      enabled: true
    }
    {
      category: 'TableUsageStatistics'
      categoryGroup: null
      enabled: true
    }
    {
      category: 'TableDetails'
      categoryGroup: null
      enabled: true
    }
    {
      category: 'Journal'
      categoryGroup: null
      enabled: true
    }
    ]
    workspaceId: LAWorkspaceID
  }
}


resource stgManagedPE 'Microsoft.Kusto/Clusters/ManagedPrivateEndpoints@2022-12-29' = {
  parent: adxCluster
  name: 'test-pe-stg-acc-01'
  properties: {
    privateLinkResourceId: storageAccounts_MPE_RID
    groupId: 'blob'
    requestMessage: 'Please approve'
  }
}
