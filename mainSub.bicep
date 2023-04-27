targetScope = 'subscription'

param rgName string = 'mybiceptest-rg'
param rglocation string = 'canada central'

//storage account module parameters
param stgName string
param stgLocation string = rglocation
param stgKind string
param stgSku string

//Resources:
//Resource Groups
resource rg01 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: rgName
  location: rglocation
}

module stgModule 'modules/stgAccModule.bicep' = {
  // scope: resourceGroup(rg01.name)
  // or 
  scope: rg01
  name: 'stgModule'
  params: {
    stgName: stgName
    stgLocation: stgLocation
    stgKind: stgKind
    stgSku: stgSku
  }
}

