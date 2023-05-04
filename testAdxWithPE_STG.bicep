param resLocation string = 'eastus'
param vnetID string = '/subscriptions/0cfe2870-d256-4119-b0a3-16293ac11bdc/resourceGroups/1-e1215295-playground-sandbox/providers/Microsoft.Network/virtualNetworks/vnet01'
param subnetID string = '/subscriptions/0cfe2870-d256-4119-b0a3-16293ac11bdc/resourceGroups/1-e1215295-playground-sandbox/providers/Microsoft.Network/virtualNetworks/vnet01/subnets/default'

resource adxCluster 'Microsoft.Kusto/clusters@2022-12-29' = {
  name: 'mytestanirudhrastg123'
  location: resLocation
  sku: {
    name: 'Standard_E8ads_v5'
    tier: 'Standard'
  }
  identity:{
    type: 'SystemAssigned'
  }
  properties:{
    enableStreamingIngest: false
    enablePurge: false
    enableAutoStop: true 
    enableDiskEncryption: false 
    enableDoubleEncryption: false
    publicNetworkAccess: 'Disabled' 
    optimizedAutoscale: {
      isEnabled: true 
      maximum: 3
      minimum: 2
      version: 1
    }
  }
}


resource adxPE 'Microsoft.Network/privateEndpoints@2022-01-01' = {
  name: 'test-adx-pe'
  location: resLocation
  properties: {
    privateLinkServiceConnections: [
      {
        name: 'test-adx-pe'
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
      id: subnetID
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
      id: vnetID
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
      id: vnetID
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
      id: vnetID
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
      id: vnetID
    }
  }
}


resource privateEndpointsDnsGroups 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2022-09-01' = {
  name: '${adxPE.name}/default'
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
