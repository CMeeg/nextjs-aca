param name string
param location string = resourceGroup().location
param tags object = {}
param containerAppEnvironmentName string
param userAssignedIdentityId string
param containerRegistryName string
param storageAccountName string
param fileShareName string

param allowedOrigins array = []
param certificateId string = ''
param containerCpuCoreCount string = '0.5'
param containerMaxReplicas int = 1
param containerMemory string = '1.0Gi'
param containerMinReplicas int = 0
param containerName string = 'main'
param customDomainName string = ''
param env array = []
param proxyEnv array = []
param external bool = true
param imageName string = ''
param ingressEnabled bool = true
param revisionMode string = 'Single'
param secrets array = []
param serviceBinds array = []
param serviceType string = ''
param targetPort int = 80

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' existing = {
  name: storageAccountName
}

resource fileService 'Microsoft.Storage/storageAccounts/fileServices@2022-09-01' = {
  name: 'default'
  parent: storageAccount
}

resource environment 'Microsoft.App/managedEnvironments@2023-05-01' existing = {
  name: containerAppEnvironmentName
}

var proxyCaddyfileStorageName = 'proxy-caddyfile'

resource proxyCaddyfileFileShare 'Microsoft.Storage/storageAccounts/fileServices/shares@2022-09-01' = {
  name: proxyCaddyfileStorageName
  parent: fileService
  properties: {
    accessTier: 'Hot'
    enabledProtocols: 'SMB'
  }
}

resource proxyCaddyfileStorage 'Microsoft.App/managedEnvironments/storages@2023-05-01' = {
  name: proxyCaddyfileStorageName
  parent: environment
  dependsOn: [
    proxyCaddyfileFileShare
  ]
  properties: {
    azureFile: {
      accessMode: 'ReadWrite'
      accountName: storageAccountName
      accountKey: storageAccount.listKeys().keys[0].value
      shareName: proxyCaddyfileStorageName
    }
  }
}

var proxyDataStorageName = 'proxy-data'

resource proxyDataFileShare 'Microsoft.Storage/storageAccounts/fileServices/shares@2022-09-01' = {
  name: proxyDataStorageName
  parent: fileService
  properties: {
    accessTier: 'Hot'
    enabledProtocols: 'SMB'
  }
}

resource proxyDataStorage 'Microsoft.App/managedEnvironments/storages@2023-05-01' = {
  name: proxyDataStorageName
  parent: environment
  dependsOn: [
    proxyDataFileShare
  ]
  properties: {
    azureFile: {
      accessMode: 'ReadWrite'
      accountName: storageAccountName
      accountKey: storageAccount.listKeys().keys[0].value
      shareName: proxyDataStorageName
    }
  }
}

var proxyConfigStorageName = 'proxy-config'

resource proxyConfigFileShare 'Microsoft.Storage/storageAccounts/fileServices/shares@2022-09-01' = {
  name: proxyConfigStorageName
  parent: fileService
  properties: {
    accessTier: 'Hot'
    enabledProtocols: 'SMB'
  }
}

resource proxyConfigStorage 'Microsoft.App/managedEnvironments/storages@2023-05-01' = {
  name: proxyConfigStorageName
  parent: environment
  dependsOn: [
    proxyConfigFileShare
  ]
  properties: {
    azureFile: {
      accessMode: 'ReadWrite'
      accountName: storageAccountName
      accountKey: storageAccount.listKeys().keys[0].value
      shareName: proxyConfigStorageName
    }
  }
}

resource containerApp 'Microsoft.App/containerApps@2023-05-01' = {
  name: name
  location: location
  tags: tags
  dependsOn: [
    proxyCaddyfileStorage
    proxyDataStorage
    proxyConfigStorage
  ]
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userAssignedIdentityId}': {}
    }
  }
  properties: {
    managedEnvironmentId: environment.id
    configuration: {
      activeRevisionsMode: revisionMode
      ingress: ingressEnabled ? {
        external: external
        targetPort: targetPort
        transport: 'auto'
        corsPolicy: {
          allowedOrigins: union([ 'https://portal.azure.com', 'https://ms.portal.azure.com' ], allowedOrigins)
        }
        customDomains: !empty(customDomainName) ? [
          {
            name: customDomainName
            certificateId: !empty(certificateId) ? certificateId : null
            bindingType: !empty(certificateId) ? 'SniEnabled' : 'Disabled'
          }
        ] : null
      } : null
      dapr: { enabled: false }
      secrets: secrets
      service: !empty(serviceType) ? { type: serviceType } : null
      registries: [
        {
          server: '${containerRegistryName}.azurecr.io'
          identity: userAssignedIdentityId
        }
      ]
    }
    template: {
      serviceBinds: !empty(serviceBinds) ? serviceBinds : null
      containers: [
        {
          image: imageName
          name: containerName
          env: env
          resources: {
            cpu: json(containerCpuCoreCount)
            memory: containerMemory
          }
        }
        {
          image: 'caddy:2.7.5-alpine'
          name: '${containerName}-proxy'
          env: proxyEnv
          resources: {
            cpu: json(containerCpuCoreCount)
            memory: containerMemory
          }
          volumeMounts: [
            {
              volumeName: proxyCaddyfileStorageName
              mountPath: '/etc/caddy'
            }
            {
              volumeName: proxyDataStorageName
              mountPath: '/data'
            }
            {
              volumeName: proxyConfigStorageName
              mountPath: '/config'
            }
          ]
        }
      ]
      scale: {
        minReplicas: containerMinReplicas
        maxReplicas: containerMaxReplicas
      }
      volumes: [
        {
          name: proxyCaddyfileStorageName
          storageType: 'AzureFile'
          storageName: proxyCaddyfileStorageName
        }
        {
          name: proxyDataStorageName
          storageType: 'AzureFile'
          storageName: proxyDataStorageName
        }
        {
          name: proxyConfigStorageName
          storageType: 'AzureFile'
          storageName: proxyConfigStorageName
        }
      ]
    }
  }
}

output id string = containerApp.id
output name string = containerApp.name
output serviceBind object = !empty(serviceType) ? { serviceId: containerApp.id, name: name } : {}
output fqdn string = ingressEnabled ? containerApp.properties.configuration.ingress.fqdn : ''
output uri string = ingressEnabled ? 'https://${containerApp.properties.configuration.ingress.fqdn}' : ''
