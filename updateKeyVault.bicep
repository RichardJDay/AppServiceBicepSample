param longAppServiceName string
param shortAppServiceName string

resource appService 'Microsoft.Web/sites@2021-02-01' existing = {
  name: longAppServiceName
}

resource keyVaultAccessPolicies 'Microsoft.KeyVault/vaults/accessPolicies@2021-06-01-preview' = {
  name: '${shortAppServiceName}/add'
  properties: {
    accessPolicies: [
      {
        tenantId: appService.identity.tenantId
        objectId: appService.identity.principalId
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
