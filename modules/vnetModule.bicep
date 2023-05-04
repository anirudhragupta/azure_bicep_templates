param vNetName string
param vNetLocation string
param defaultSubnetName string = 'default'
param pepSubnetName string = 'PEP-Subnet'

resource vNet 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: vNetName
  location: vNetLocation
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
  }
}

resource defultSubnet 'Microsoft.Network/virtualNetworks/subnets@2022-09-01' = {
  parent: vNet
  name: defaultSubnetName
  properties: {
    addressPrefix: '10.0.0.0/24'
  }
}

resource pepSubnet 'Microsoft.Network/virtualNetworks/subnets@2022-09-01' = {
  parent: vNet
  name: pepSubnetName
  properties: {
    addressPrefix: '10.0.0.0/24'
  }
}

output vnet_RID string = vNet.id
output subnet_RID string = pepSubnet.id
