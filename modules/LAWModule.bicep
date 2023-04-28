//Parameters:
//LA Workspace Parameters
param lawLocation string = 'canada central'

param lawName string

@maxValue(365)
param retentionInDays int = 30

//Resources:
//LA Workspace
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' = {
  name: lawName
  location: lawLocation
  properties: {
    retentionInDays: retentionInDays
  }
}

output resourceID string = logAnalyticsWorkspace.id
