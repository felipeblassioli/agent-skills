# 1. Login and capture the token
POST {{base_url}}/login
[Form]
username: {{username}}
password: {{password}}
HTTP 200
[Captures]
token: jsonpath "$.token"

# 2. Use the captured token in a subsequent request
GET {{base_url}}/protected/resource
Authorization: Bearer {{token}}
HTTP 200
[Asserts]
jsonpath "$.data" exists
