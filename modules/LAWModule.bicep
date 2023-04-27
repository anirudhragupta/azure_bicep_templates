//Parameters:
//LA Workspace Parameters
@allowed([
  'canada central'
])
param location string = 'canada central'

param name string

@maxValue(365)
param retentionInDays int

//Resources:
//LA Workspace
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' = {
  name: name
  location: location
  properties: {
    retentionInDays: retentionInDays
  }
}
