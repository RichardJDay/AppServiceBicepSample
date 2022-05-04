targetScope = 'subscription'

param infrastructureVersionNumber string
param appServiceName string
param environmentName string
param versionNumber string
param location string = 'uksouth'

var resourceGroupName = '${replace(appServiceName, '-', '.')}.${versionNumber}'
var longAppServiceName = '${appServiceName}-${environmentName}-${versionNumber}'
var shortAppServiceName = replace(replace(longAppServiceName, 'Simply-App-', ''), 'Simply-Api-', '')

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
} 

module appInsights './appInsights.bicep' = {
  name: 'appInsights'
  scope: resourceGroup   
  params: {
    infrastructureVersionNumber: infrastructureVersionNumber
    environmentName: environmentName
    longAppServiceName: longAppServiceName
    shortAppServiceName: shortAppServiceName
    location: location
  }
}

module keyVault './keyVault.bicep' = {
  name: 'keyVault'
  scope: resourceGroup   
  params: {
    infrastructureVersionNumber: infrastructureVersionNumber
    environmentName: environmentName
    appServiceName: appServiceName
    shortAppServiceName: shortAppServiceName
    location: location
  }
}

module appService './appService.bicep' = {
  name: 'appService'
  scope: resourceGroup   
  params: {
    infrastructureVersionNumber: infrastructureVersionNumber    
    environmentName: environmentName
    longAppServiceName: longAppServiceName
    shortAppServiceName: shortAppServiceName    
    location: location
  }
  dependsOn:[
    appInsights
    keyVault
  ]
}

module updateKeyVault './updateKeyVault.bicep' = {
  name: 'updateKeyVault'
  scope: resourceGroup   
  params: {
    longAppServiceName: longAppServiceName
    shortAppServiceName: shortAppServiceName
  }
  dependsOn:[
    appService
  ]
}
