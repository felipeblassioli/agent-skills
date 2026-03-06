# A simple GET request
GET {{base_url}}/api/health
HTTP 200
[Asserts]
jsonpath "$.status" == "ok"

# A POST request with JSON body
POST {{base_url}}/api/users
{
    "name": "Alice",
    "email": "alice@example.com"
}
HTTP 201
[Asserts]
jsonpath "$.id" exists
