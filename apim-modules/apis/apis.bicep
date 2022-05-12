param apimInstance object
param apimEnv string

module testerFunctionApi 'TesterFunctionApi/TesterFunctionApi.bicep' = {
  name: 'funcApi'
  params: {
    apimName: apimInstance.name
    funcAppName: 'FuncAppWithSwagger'
    apiEnv: apimEnv
  }
}
