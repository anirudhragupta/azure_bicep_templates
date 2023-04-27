param stgName string
param stgLocation string
param stgKind string
param stgSku string

resource stgAcc 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: stgName
  location: stgLocation
  kind: stgKind
  sku: {
    name: stgSku
  }
}

output resourceID string = stgAcc.id
