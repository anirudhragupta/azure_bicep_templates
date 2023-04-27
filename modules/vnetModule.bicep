param vNetName string
param vNetLocation string
param subnet1Name string = 'default'
param subnet2Name string = 'PEP-Subnet'

resource vNet 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: vNetName
  location: vNetLocation
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: subnet1Name
        properties: {
          addressPrefix: '10.0.0.0/24'
        }
      }
      {
        name: subnet2Name
        properties: {
          addressPrefix: '10.0.1.0/24'
        }
      }
    ]
  }
}
