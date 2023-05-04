//Parameters:
//ADX Cluster Parameters
@allowed([
  'leader'
  'follower'
])
param leaderOrFollower string = 'follower'
var dbCreate = (leaderOrFollower == 'leader')

param adxLocation string = 'eastus'

@description('Enter a globally unique name for the ADX cluster')
@maxLength(22)
@minLength(5)
param clusterName string = 'mytstlabaidhrjt123'

@allowed([
  'Standard_L8as_v3' //Storage Optimized -- Leader Cluster
  'Standard_E8ads_v5' //Compute Optimized -- Follower Cluster
  'Dev(No SLA)_Standard_D11_v2' //Dev
])
param clusterSKU string = 'Standard_L8as_v3'

param optimizedAutoscale bool = false 
param maxInstance int = 3 
@minValue(2)
param minInstance int = 2

@allowed([
  'Basic'
  'Standard'
])
param clusterTier string = 'Standard'

//ADX Cluster Properties Parameters
param enableStreamingIngest bool = false 
param enablePurge bool = false
param enableAutoStop bool = true
param enableDiskEncryption bool = false
param enableDoubleEncryption bool = false
param publicNetworkAccess string = 'Disabled'

@allowed([
  'SystemAssigned'
  'UserAssigned' 
  'SystemAssigned, UserAssigned'
  'None'
])
param clusterIdentity string = 'SystemAssigned'

//Cluster Database Parameters
param databaseName string = 'mytestdb'

@allowed([
  'ReadWrite'
  'ReadOnlyFollowing'
])
param dbKind string = 'ReadWrite'

// Diagnostic Settings Parameter
// param diagnostsicSettingName string 

// @description('Full ARM resource ID of the Log Analytics workspace to which you would like to send Diagnostic Logs')
// param LAWorkspace_RID string 

//Managed Private Endpoint
// param storageAccount_MPE_RID string
// param adxMPEName string 

//Private Endpoints parameters
param adxPEName string = 'adx-pe-test-01'
param dnsGroupName string = 'adx-dns-group-01'
param vnet_RID string = '/subscriptions/2213e8b1-dbc7-4d54-8aff-b5e315df5e5b/resourcegroups/1-c11a7dcd-playground-sandbox/providers/Microsoft.Network/virtualNetworks/vnet01'
param subnet_RID string = '/subscriptions/2213e8b1-dbc7-4d54-8aff-b5e315df5e5b/resourcegroups/1-c11a7dcd-playground-sandbox/providers/Microsoft.Network/virtualNetworks/vnet01/subnets/default'


//Resources:
//ADX Cluster
resource adxCluster 'Microsoft.Kusto/clusters@2022-12-29' = {
  name: clusterName
  location: adxLocation
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
    optimizedAutoscale: (clusterSKU != 'Dev(No SLA)_Standard_D11_v2') ? {
      isEnabled: optimizedAutoscale 
      maximum: maxInstance
      minimum: minInstance
      version: 1
    } : null
  }

//ADX Database Resource
  resource database01 'databases@2022-12-29' = if (dbCreate)  {
    name: databaseName
    location: adxLocation
    kind: dbKind
  }
}

// //Cluster Diagnostic Settings
// resource clusterLogsDiagnostic 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
//   name: diagnostsicSettingName
//   scope: adxCluster
//   properties: {
//     logs:[
//     {
//       category: 'SucceededIngestion'
//       categoryGroup: null
//       enabled: true
//     }
//     {
//       category: 'FailedIngestion'
//       categoryGroup: null
//       enabled: true
//     }
//     {
//       category: 'IngestionBatching'
//       categoryGroup: null
//       enabled: true
//     }
//     {
//       category: 'Command'
//       categoryGroup: null
//       enabled: true
//     }
//     {
//       category: 'Query'
//       categoryGroup: null
//       enabled: true
//     }
//     {
//       category: 'TableUsageStatistics'
//       categoryGroup: null
//       enabled: true
//     }
//     {
//       category: 'TableDetails'
//       categoryGroup: null
//       enabled: true
//     }
//     {
//       category: 'Journal'
//       categoryGroup: null
//       enabled: true
//     }
//   ]
//   workspaceId: LAWorkspace_RID
//   }
// }

// //Managed Private Endpoints
// resource stgManagedPE 'Microsoft.Kusto/Clusters/ManagedPrivateEndpoints@2022-12-29' = {
//   parent: adxCluster
//   name: adxMPEName
//   properties: {
//     privateLinkResourceId: storageAccount_MPE_RID
//     groupId: 'blob'
//     requestMessage: 'Please approve'
//   }
// }


//ADX Cluster Private Endpoints and Private DNS
resource adxPE 'Microsoft.Network/privateEndpoints@2022-01-01' = {
  name: adxPEName
  location: adxLocation
  properties: {
    privateLinkServiceConnections: [
      {
        name: adxPEName
        properties: {
          privateLinkServiceId: adxCluster.id
          groupIds: [
            'cluster'
          ]
          privateLinkServiceConnectionState:{
            status: 'Approved'
            actionsRequired: 'None'
          }
        }
      }
    ]
    subnet: {
      id: subnet_RID
    }
  }
}


resource kustoDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.centralindia.kusto.windows.net'
  location: 'Global'
  properties: {}
}

resource blobDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.blob.${environment().suffixes.storage}'
  location: 'Global'
  properties: {}
}

resource queueDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.queue.${environment().suffixes.storage}'
  location: 'Global'
  properties: {}
}

resource tableDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.table.${environment().suffixes.storage}'
  location: 'Global'
  properties: {}
}

resource kustoDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: kustoDnsZone
  name: '${kustoDnsZone.name}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnet_RID
    }
  }
}

resource blobDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: blobDnsZone
  name: '${blobDnsZone.name}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnet_RID
    }
  }
}

resource queueDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: queueDnsZone
  name: '${queueDnsZone.name}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnet_RID
    }
  }
}

resource tableDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: tableDnsZone
  name: '${tableDnsZone.name}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnet_RID
    }
  }
}

resource privateEndpointsDnsGroups 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2022-09-01' = {
  name: dnsGroupName
  parent: adxPE
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink-canadacentral-kusto-windows-net'
        properties: {
          privateDnsZoneId: kustoDnsZone.id
        }
      }
      {
        name: 'privatelink-blob-core-windows-net'
        properties: {
          privateDnsZoneId: blobDnsZone.id
        }
      }
      {
        name: 'privatelink-queue-core-windows-net'
        properties: {
          privateDnsZoneId: queueDnsZone.id
        }
      }
      {
        name: 'privatelink-table-core-windows-net'
        properties: {
          privateDnsZoneId: tableDnsZone.id
        }
      }
    ]
  }
}
