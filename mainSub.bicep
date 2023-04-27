targetScope = 'subscription'

param rglocation string = 'canada central'
param resourceLocation string = 'canada central'

//storage account module parameters
param storageRGName string = 'mybiceptest-rg'
param stgName string
param stgKind string
param stgSku string

//LAW Module parameters
param analyticsRGName string
param LAWName string 
@maxValue(365)
param retentionInDays int

//ADX Module Parameters


//Resources:
//Resource Groups
resource storageRG 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: storageRGName
  location: rglocation
}

resource analyticsRG 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: analyticsRGName
  location: rglocation
}

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

module lawModule 'modules/LAWModule.bicep' = {
  scope: analyticsRG
  name: 'lawModule'
  params: {
    name: LAWName
    lawLocation: resourceLocation
    retentionInDays: retentionInDays
  }
}
