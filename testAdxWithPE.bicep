
//Resources:
//ADX Cluster Resource
resource adxCluster 'Microsoft.Kusto/clusters@2022-12-29' = {
  name: 'mytestanirudhra'
  location: 'central india'
  sku: {
    name: 'Dev(No SLA)_Standard_D11_v2'
    tier: 'Basic'
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
  }
}


resource adxPE 'Microsoft.Network/privateEndpoints@2022-01-01' = {
  name: 'test-adx-pe'
  location: 'central india'
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
      id: '/subscriptions/6b509e67-6a04-43f1-8e4b-3e276af8ba93/resourcegroups/anirudhra-rg/providers/Microsoft.Network/virtualNetworks/vnet01/subnets/default'
    }
  }
}


resource kustoDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.centralindia.kusto.windows.net'
  // name: 'privatelink.centralindia.${environment().}'
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
      id: '/subscriptions/6b509e67-6a04-43f1-8e4b-3e276af8ba93/resourcegroups/anirudhra-rg/providers/Microsoft.Network/virtualNetworks/vnet01'
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
      id: '/subscriptions/6b509e67-6a04-43f1-8e4b-3e276af8ba93/resourcegroups/anirudhra-rg/providers/Microsoft.Network/virtualNetworks/vnet01'
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
      id: '/subscriptions/6b509e67-6a04-43f1-8e4b-3e276af8ba93/resourcegroups/anirudhra-rg/providers/Microsoft.Network/virtualNetworks/vnet01'
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
      id: '/subscriptions/6b509e67-6a04-43f1-8e4b-3e276af8ba93/resourcegroups/anirudhra-rg/providers/Microsoft.Network/virtualNetworks/vnet01'
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
