param acrname string 
param acrloc string = 'korea south'
param appServicePlanName string
param appServicePlanLocation string = 'korea south'
param webAppName string ='Kghazzi-webapp'
param webAppLocation string = 'korea south'
param containerRegistryImageName string = 'flask-demo'
param containerRegistryImageVersion string = 'latest'
param DOCKER_REGISTRY_SERVER_USERNAME string 
@secure()
param DOCKER_REGISTRY_SERVER_PASSWORD string

module registry './ResourceModules/modules/container-registry/registry/main.bicep' = {
  name: acrname
  params: {
    name: acrname
    location: acrloc
    acrAdminUserEnabled: true
  }
}

module serverfarm './ResourceModules/modules/web/serverfarm/main.bicep' = {
  name: '${appServicePlanName}-deploy'
  params: {
    name: appServicePlanName
    location: appServicePlanLocation
    sku: {
      capacity: 1
      family: 'B'
      name: 'B1'
      size: 'B1'
      tier: 'Basic'
    }
    reserved: true
  }
}

module site './ResourceModules/modules/web/site/main.bicep' = {
  name: 'siteModule'
  params: {
    kind: 'app'
    name: webAppName
    location: webAppLocation
    serverFarmResourceId: resourceId('Microsoft.Web/serverfarms', appServicePlanName)
    siteConfig: {
      linuxFxVersion: 'DOCKER|${acrname}.azurecr.io/${containerRegistryImageName }:${containerRegistryImageVersion}'
      appCommandLine: ''
    }
    appSettingsKeyValuePairs : {
      WEBSITES_ENABLE_APP_SERVICE_STORAGE: false
      DOCKER_REGISTRY_SERVER_URL: 'https://${acrname}.azurecr.io'
      DOCKER_REGISTRY_SERVER_USERNAME: DOCKER_REGISTRY_SERVER_USERNAME
      DOCKER_REGISTRY_SERVER_PASSWORD: DOCKER_REGISTRY_SERVER_PASSWORD
    }
  }
}
