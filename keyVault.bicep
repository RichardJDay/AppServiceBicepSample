param infrastructureVersionNumber string
param environmentName string
param appServiceName string
param shortAppServiceName string
param location string

resource keyVault 'Microsoft.KeyVault/vaults@2021-06-01-preview' = {
  name: shortAppServiceName
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        objectId: 'd607db7a-94c9-47c6-b02d-dede761cf044'
        permissions: {
          secrets: [
            'list'
            'get'
            'set'
          ]
        }
      }
    ]
  }
}

resource eqpmntConnectionString 'Microsoft.KeyVault/vaults/secrets@2021-06-01-preview' = {
  parent: keyVault
  name: 'ConnectionStrings--Eqpmnt'
  properties:{
    value: 'Server=simply-sqlserver-${environmentName}-${infrastructureVersionNumber}.database.windows.net;Database=${appServiceName};User Id=PolygonAdmin;Password=P0lyg0nAdm1n'
  }
} 
