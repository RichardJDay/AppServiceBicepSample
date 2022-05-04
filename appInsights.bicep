param infrastructureVersionNumber string
param environmentName string
param longAppServiceName string
param shortAppServiceName string
param location string

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = {
  name: 'Simply-LogAnalytics-${environmentName}-${infrastructureVersionNumber}'
  scope: resourceGroup('Simply.Infrastructure.${infrastructureVersionNumber}')
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: shortAppServiceName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspace.id
  }
  tags: {
    'hidden-link:/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Web/sites/${longAppServiceName}': 'Resource'
  }
  dependsOn: [
    logAnalyticsWorkspace
  ]
}
