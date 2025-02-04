param apimName string
param funcAppName string
param apiEnv string

var funcKeyName = '${funcAppName}-key'
var policyContent = loadTextContent('TesterFunctionApi.policy.xml', 'utf-8')
var functionApiPolicy = replace(policyContent, '{funcAppName}', '${funcAppName}')

resource funcApp 'Microsoft.Web/sites@2021-03-01' existing = {
  name: funcAppName
}

resource funcHostKey 'Microsoft.Web/sites/host/functionKeys@2021-03-01' = {
  name: '${funcApp.name}/default/apim-${apimName}'
  properties: {
    name: 'apim-${apimName}'
  }
}

resource apimInstance 'Microsoft.ApiManagement/service@2021-08-01' existing = {
  name: apimName
}

resource kvAppKey 'Microsoft.ApiManagement/service/namedValues@2021-08-01' = {
  name: funcKeyName
  parent: apimInstance
  properties: {
    displayName: funcAppName
    value: funcHostKey.properties.value
    secret: true
    tags: [
      'key'
      'function'
      'auto'
      'arm'
    ]
  }
}

resource serviceBackend 'Microsoft.ApiManagement/service/backends@2021-08-01' = {
  name: funcAppName
  parent: apimInstance
  dependsOn: [
    kvAppKey
  ]
  properties: {
    description: funcAppName
    protocol: 'http'
    url: 'https://${funcAppName}.azurewebsites.net/api'
    resourceId: 'https://management.azure.com${funcApp.id}'
    credentials: {
      header: {
        'x-functions-key': [
          '{{${funcKeyName}}}'
        ]
      }
    }
  }
}

resource testerApiPolicy 'Microsoft.ApiManagement/service/apis/policies@2021-08-01' = {
  name: 'policy'
  parent: funcAppApi
  properties: {
    value: functionApiPolicy
    format: 'xml'
  }
}

resource funcConfig 'Microsoft.Web/sites/config@2021-03-01' = {
  name: 'web'
  parent: funcApp
  properties: {
    apiManagementConfig: {
      id: funcAppApi.id
    }
  }
}

resource funcAppApi 'Microsoft.ApiManagement/service/apis@2021-08-01' = {
  name: 'tester-func-${apiEnv}'
  parent: apimInstance
  dependsOn: [
    serviceBackend
  ]
  properties: {
    displayName: 'Tester Function API'
    path: 'functionapi'
    protocols: [
      'https'
    ]
    apiType: 'http'
    isCurrent: true
    subscriptionRequired: false
  }
}

resource weatherOp 'Microsoft.ApiManagement/service/apis/operations@2021-08-01' = {
  name: 'weather'
  parent: funcAppApi
  properties: {
    urlTemplate: '/weather'
    method: 'GET'
    displayName: 'GET Weather'
    request: {
      queryParameters: [
        {
          name: 'name'
          type: 'string'
        }
      ]
    }
    responses: [
      {
        description: 'return success'
        statusCode: 200
      }
      {
        description: 'not authorized'
        statusCode: 401
      }
    ]
  }
}
