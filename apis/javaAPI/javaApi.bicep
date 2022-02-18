param apimServiceName string
param apimEnv string

var envConfigMap = {
  dev: {
    url: 'https://api-dev-amtf7sehwlmdi.azurewebsites.net'
  }
  staging: {
    url: 'https://api-staging-z5dlqnsfvnwaw.azurewebsites.net'
  }
  prod: {
    url: 'https://api-prod-4iexmenv2zf6g.azurewebsites.net'
  }
}

resource javaApi 'Microsoft.ApiManagement/service/apis@2021-08-01' = {
  name: '${apimServiceName}/javaApi'
  properties: {
    path: 'javaApi'
    apiRevision: '1'
    apiRevisionDescription: 'initial api'
    displayName: 'java api'
    subscriptionRequired: false
    serviceUrl: envConfigMap[apimEnv].url
    protocols: [
      'https' 
    ]
    format: 'openapi+json'
    value: loadTextContent('openapi.json')
  }
}
