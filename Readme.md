# Fudo API

## Exercise

See [Exercise.md](Exercise.md) for app requirements.

## Test API

#### OpenAPI

npm install @openapitools/openapi-generator-cli -g
openapi-generator-cli generate -i public/openapi.yaml -g javascript -o ./fudo-client

#### Postman

import fudo_api_collection.json
