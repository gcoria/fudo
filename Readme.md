# Fudo API

## Features

- Token-based authentication system
- Asynchronous product creation with background job processing
- Product listing with authenticated access
- OpenAPI specification for API documentation and client generation
- Compressed responses (gzip) support
- Static file serving with cache control

## Tech Stack

- Ruby 3.2
- Rack
- In-memory data storage
- Background job processing
- Docker
- OpenAPI 3.0 specification

## Exercise

See [Exercise.md](Exercise.md) for app requirements.

## Installation and Usage

### Docker

1. Build the Docker image:

   ```
   docker build -t fudo-api .
   ```

2. Run the container:

   ```
   docker run -p 9292:9292 fudo-api
   ```

3. The API will be available at `http://localhost:9292`

### Without Docker

1. Requirements:

   - Ruby 3.2 or higher
   - Bundler

2. Install dependencies:

   ```
   bundle install
   ```

3. Run the application:

   ```
   bundle exec rackup -p 9292
   ```

4. The API will be available at `http://localhost:9292`

## Running Tests

Run all tests with:

```
bundle exec rake test
```

## Test API

#### OpenAPI

1. Install OpenAPI cli

```
npm install @openapitools/openapi-generator-cli -g
```

2. Generate Cli

```
openapi-generator-cli generate -i public/openapi.yaml -g javascript -o ./fudo-client
```

#### Postman

```
import fudo_api_collection.json
```
