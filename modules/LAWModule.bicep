//Parameters:
//LA Workspace Parameters
param lawLocation string = 'canada central'

param name string

@maxValue(365)
param retentionInDays int

//Resources:
//LA Workspace
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' = {
  name: name
  location: lawLocation
  properties: {
    retentionInDays: retentionInDays
  }
}

output resourceID string = logAnalyticsWorkspace.id
