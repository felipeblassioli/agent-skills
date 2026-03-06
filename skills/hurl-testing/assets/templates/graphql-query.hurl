# A GraphQL query
POST {{base_url}}/graphql
```graphql
{
  human(id: "1000") {
    name
    height
  }
}
```
HTTP 200
[Asserts]
jsonpath "$.data.human.name" == "Luke Skywalker"
