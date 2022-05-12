param apimInstanceName string

resource apimTestProduct 'Microsoft.ApiManagement/service/products@2021-08-01' = {
  name: '${apimInstanceName}/apimTestProduct'
  properties: {
    displayName: 'Tester Product'
    description: 'My first example product'
    subscriptionRequired: true
    state: 'published'
  }

  resource devGroup 'groups' = {
    name: 'Developers'
  }

  resource guestGroup 'groups' = {
    name: 'Guests'
  }

  resource adminGroup 'groups' = {
    name: 'Administrators'
  }
}
