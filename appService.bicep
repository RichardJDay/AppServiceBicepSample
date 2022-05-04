param infrastructureVersionNumber string
param environmentName string
param longAppServiceName string
param shortAppServiceName string
param location string

resource appServicePlan 'Microsoft.Web/serverfarms@2021-02-01' existing = {
  name: 'Simply-AppServicePlan-${environmentName}-${infrastructureVersionNumber}'
  scope: resourceGroup('Simply.Infrastructure.${infrastructureVersionNumber}')
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2021-03-01' existing = {
  name: 'Simply-VNet-${environmentName}-${infrastructureVersionNumber}'
  scope: resourceGroup('Simply.Infrastructure.${infrastructureVersionNumber}')
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: shortAppServiceName
}

resource keyVault 'Microsoft.KeyVault/vaults@2021-06-01-preview' existing = {
  name: shortAppServiceName
}

resource appService 'Microsoft.Web/sites@2021-02-01' = {
  name: longAppServiceName
  location: location
  kind: 'app'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlan.id
    virtualNetworkSubnetId: '${virtualNetwork.id}/subnets/AppService'
    httpsOnly: true
    clientAffinityEnabled: false
    siteConfig: {
      minTlsVersion: '1.2'
      alwaysOn: true
      appSettings: [
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: applicationInsights.properties.InstrumentationKey
        }
        {
          name: 'APPINSIGHTS_PROFILERFEATURE_VERSION'
          value: '1.0.0'
        }
        {
          name: 'APPINSIGHTS_SNAPSHOTFEATURE_VERSION'
          value: '1.0.0'
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: 'InstrumentationKey=${applicationInsights.properties.InstrumentationKey}'
        }
        {
          name: 'ApplicationInsightsAgent_EXTENSION_VERSION'
          value: '~2'
        }
        {
          name: 'ASPNETCORE_ENVIRONMENT'
          value: environmentName == 'Dev' ? 'Development' : environmentName == 'UAT' ? 'Staging' : 'Production'
        }
        {
          name: 'DiagnosticServices_EXTENSION_VERSION'
          value: '~3'
        }
        {
          name: 'InstrumentationEngine_EXTENSION_VERSION'
          value: '~1'
        }
        {
          name: 'KeyVault:BaseUrl'
          value: keyVault.properties.vaultUri
        }
        {
          name: 'MSDEPLOY_RENAME_LOCKED_FILES'
          value: '1'
        }
        {
          name: 'SnapshotDebugger_EXTENSION_VERSION'
          value: '~1'
        }
        {
          name: 'WEBSITE_RUN_FROM_PACKAGE'
          value: '1'
        }
        {
          name: 'WEBSITE_TIME_ZONE'
          value: 'GMT Standard Time'
        }
        {
          name: 'XDT_MicrosoftApplicationInsights_BaseExtensions'
          value: '~1'
        }
        {
          name: 'XDT_MicrosoftApplicationInsights_Mode'
          value: 'recommended'
        }
      ]
    }
  }
  resource config 'config@2021-02-01' = {
    name: 'web'
    properties: {
      vnetName: 'AppService'
      vnetRouteAllEnabled: true
      ipSecurityRestrictions: [
        {
          priority: 0
          name: 'AppService'
          vnetSubnetResourceId: '/subscriptions/${subscription().subscriptionId}/resourceGroups/Simply.Infrastructure.${infrastructureVersionNumber}/providers/Microsoft.Network/virtualNetworks/Simply-VNet-${environmentName}-${infrastructureVersionNumber}/subnets/AppService'
        }
      ]
    }
  }
}
