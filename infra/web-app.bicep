param name string
param location string = resourceGroup().location
param tags object = {}
param exists bool = false
param containerAppEnvironmentId string
param userAssignedIdentityId string
param containerRegistryName string

param allowedOrigins array = []
param certificateId string = ''
param containerCpuCoreCount string = '0.5'
param containerMaxReplicas int = 1
param containerMemory string = '1.0Gi'
param containerMinReplicas int = 0
param containerName string = 'main'
param customDomainName string = ''
param env array = []
param external bool = true
param imageName string = ''
param ingressEnabled bool = true
param revisionMode string = 'Single'
param secrets array = []
param serviceBinds array = []
param serviceType string = ''
param targetPort int = 80

resource existingApp 'Microsoft.App/containerApps@2023-05-01' existing = if (exists) {
  name: name
}

module containerApp './containers/container-app.bicep' = {
  name: '${deployment().name}-container-app'
  params: {
    name: name
    location: location
    tags: tags
    containerAppEnvironmentId: containerAppEnvironmentId
    userAssignedIdentityId: userAssignedIdentityId
    containerRegistryName: containerRegistryName
    containerName: containerName
    imageName: !empty(imageName) ? imageName : exists ? existingApp.properties.template.containers[0].image : 'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest'
    external: external
    ingressEnabled: ingressEnabled
    revisionMode: revisionMode
    secrets: secrets
    serviceBinds: serviceBinds
    serviceType: serviceType
    allowedOrigins: allowedOrigins
    containerCpuCoreCount: containerCpuCoreCount
    containerMemory: containerMemory
    containerMinReplicas: containerMinReplicas
    containerMaxReplicas: containerMaxReplicas
    customDomainName: customDomainName
    certificateId: certificateId
    env: env
    targetPort: targetPort
  }
}

output id string = containerApp.outputs.id
output name string = containerApp.outputs.name
output serviceBind object = containerApp.outputs.serviceBind
output fqdn string = containerApp.outputs.fqdn
output uri string = containerApp.outputs.uri
