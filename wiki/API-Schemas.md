# API Schemas

Complete documentation of the TDX API specifications and OAuth flow used by the TDX Feedback Gem.

## 📊 Overview

This gem integrates with the TeamDynamix (TDX) API system. The complete API specifications are included in the `docs/` directory for reference and development purposes.

## 🔑 Schema Files

### `docs/tdxticket.yaml` - TDX Ticket API Specification

**Purpose**: Complete OpenAPI 3.0.1 specification for the TDX ticket management system.

**What it contains**:
- All available API endpoints for ticket operations
- Request/response schemas and data models
- Authentication requirements and error handling
- Field definitions and validation rules

**Key endpoints documented**:
- Ticket creation, updates, and management
- Asset management and search
- Knowledge base operations
- User and group management
- Report generation and access

**How to use it**:
- **Development**: Reference exact field names, data types, and API structure
- **Testing**: Generate mock data based on documented schemas
- **Integration**: Understand required parameters and response formats
- **Troubleshooting**: Verify API behavior against documented specifications

**Example usage in development**:
```ruby
# Reference the schema to understand ticket structure
# From tdxticket.yaml, we know tickets require:
# - appId (integer)
# - typeId (integer)
# - statusId (integer)
# - sourceId (integer)
# - serviceId (integer)
# - responsibleGroupId (integer)

# This helps ensure your configuration matches the API requirements
```

### `docs/oauthtokenprovider.yaml` - OAuth Token Provider API

**Purpose**: OpenAPI specification for the OAuth2 client credentials flow used for API authentication.

**What it contains**:
- Token endpoint specifications
- Required parameters (scope, grant_type)
- Response schemas (access_token, expires_in, etc.)
- Error handling and status codes

**How to use it**:
- **Authentication**: Understand the OAuth flow requirements
- **Token Management**: Know how to request and handle access tokens
- **Error Handling**: Properly handle authentication failures

**Example usage in development**:
```ruby
# From oauthtokenprovider.yaml, we know the token endpoint requires:
# - scope: 'tdxticket' (as configured in your gem)
# - grant_type: 'client_credentials'
# - Basic auth with client_id/client_secret

# This ensures your OAuth implementation matches the API specification
```

## 🔄 OAuth Flow

### Client Credentials Flow

The gem uses the OAuth2 client credentials flow for API authentication:

```mermaid
sequenceDiagram
    participant App as Your App
    participant TDX as TDX API
    participant OAuth as OAuth Server

    App->>OAuth: POST /oauth2/token
    Note over App,OAuth: Basic Auth + client_credentials
    OAuth->>App: Access Token + expires_in
    App->>TDX: API Request + Bearer Token
    TDX->>App: API Response
```

### Token Request

```bash
# Request OAuth token
curl -X POST "https://api.example.com/" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -H "Authorization: Basic $(echo -n 'client_id:client_secret' | base64)" \
  -d "grant_type=client_credentials&scope=tdxticket"
```

**Request Parameters**:
- `grant_type`: Must be `client_credentials`
- `scope`: Must be `tdxticket`
- `Authorization`: Basic auth with client_id:client_secret

**Response**:
```json
{
  "access_token": "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "Bearer",
  "expires_in": 3600,
  "scope": "tdxticket"
}
```

### Token Usage

```bash
# Use access token for API requests
curl -X GET "https://api.example.com//tickets" \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9..."
```

## 🎫 Ticket Creation API

### Create Ticket Endpoint

**Endpoint**: `POST /tickets`

**Request Headers**:
```
Authorization: Bearer {access_token}
Content-Type: application/json
```

**Request Body**:
```json
{
  "appId": 31,
  "typeId": 12,
  "statusId": 77,
  "sourceId": 8,
  "serviceId": 67,
  "responsibleGroupId": 631,
  "title": "[Feedback] User feedback message",
  "description": "User feedback message\n\nContext: Additional context information",
  "requestorId": "user@example.com",
  "priorityId": 2,
  "urgencyId": 2,
  "impactId": 2
}
```

**Required Fields**:
- `appId`: Application ID in TDX
- `typeId`: Ticket type ID
- `statusId`: Initial status ID
- `sourceId`: Ticket source ID
- `serviceId`: Service ID
- `responsibleGroupId`: Responsible group ID
- `title`: Ticket title
- `description`: Ticket description

**Optional Fields**:
- `requestorId`: Email of the person requesting the ticket
- `priorityId`: Priority level
- `urgencyId`: Urgency level
- `impactId`: Impact level
- `customAttributes`: Custom form fields

### Response

**Success Response**:
```json
{
  "id": 12345,
  "ticketNumber": "TDX-2024-001",
  "title": "[Feedback] User feedback message",
  "status": "New",
  "priority": "Medium",
  "createdDate": "2024-01-15T10:30:00Z",
  "requestor": "user@example.com"
}
```

**Error Response**:
```json
{
  "error": "Validation failed",
  "details": [
    "AppId is required",
    "TypeId must be a valid ticket type"
  ]
}
```

## 🔍 API Endpoints Reference

### Authentication

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/um/oauth2/token` | POST | Get OAuth access token |

### Tickets

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/um/it/tickets` | GET | List tickets |
| `/um/it/tickets` | POST | Create new ticket |
| `/um/it/tickets/{id}` | GET | Get ticket details |
| `/um/it/tickets/{id}` | PUT | Update ticket |
| `/um/it/tickets/{id}` | DELETE | Delete ticket |

### Applications

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/um/it/apps` | GET | List applications |
| `/um/it/apps/{id}` | GET | Get application details |

### Ticket Types

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/um/it/tickettypes` | GET | List ticket types |
| `/um/it/tickettypes/{id}` | GET | Get ticket type details |

### Statuses

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/um/it/statuses` | GET | List statuses |
| `/um/it/statuses/{id}` | GET | Get status details |

## 📋 Field Definitions

### Ticket Fields

#### Required Fields

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `appId` | integer | Application ID in TDX | 31 |
| `typeId` | integer | Ticket type ID | 12 |
| `statusId` | integer | Initial status ID | 77 |
| `sourceId` | integer | Ticket source ID | 8 |
| `serviceId` | integer | Service ID | 67 |
| `responsibleGroupId` | integer | Responsible group ID | 631 |
| `title` | string | Ticket title | "[Feedback] User feedback" |
| `description` | string | Ticket description | "User feedback message" |

#### Optional Fields

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `requestorId` | string | Requestor email | "user@example.com" |
| `priorityId` | integer | Priority level | 2 |
| `urgencyId` | integer | Urgency level | 2 |
| `impactId` | integer | Impact level | 2 |
| `customAttributes` | object | Custom form fields | `{"field1": "value1"}` |

### Priority Levels

| ID | Name | Description |
|----|------|-------------|
| 1 | Low | Low priority tickets |
| 2 | Medium | Medium priority tickets |
| 3 | High | High priority tickets |
| 4 | Critical | Critical priority tickets |

### Urgency Levels

| ID | Name | Description |
|----|------|-------------|
| 1 | Low | Low urgency |
| 2 | Medium | Medium urgency |
| 3 | High | High urgency |
| 4 | Critical | Critical urgency |

### Impact Levels

| ID | Name | Description |
|----|------|-------------|
| 1 | Low | Low impact |
| 2 | Medium | Medium impact |
| 3 | High | High impact |
| 4 | Critical | Critical impact |

## 🚨 Error Handling

### HTTP Status Codes

| Status | Meaning | Description |
|--------|---------|-------------|
| 200 | OK | Request successful |
| 201 | Created | Resource created successfully |
| 400 | Bad Request | Invalid request parameters |
| 401 | Unauthorized | Invalid or expired token |
| 403 | Forbidden | Insufficient permissions |
| 404 | Not Found | Resource not found |
| 422 | Unprocessable Entity | Validation failed |
| 429 | Too Many Requests | Rate limit exceeded |
| 500 | Internal Server Error | Server error |

### Error Response Format

```json
{
  "error": "Error message",
  "details": [
    "Detailed error 1",
    "Detailed error 2"
  ],
  "requestId": "req-12345",
  "timestamp": "2024-01-15T10:30:00Z"
}
```

### Common Error Scenarios

#### Authentication Errors

```json
{
  "error": "invalid_client",
  "error_description": "Client authentication failed"
}
```

**Solutions**:
- Verify client_id and client_secret
- Check if credentials are correct
- Ensure OAuth scope is `tdxticket`

#### Validation Errors

```json
{
  "error": "Validation failed",
  "details": [
    "AppId is required",
    "TypeId must be a valid ticket type"
  ]
}
```

**Solutions**:
- Check required field values
- Verify field types and formats
- Ensure values exist in TDX system

#### Rate Limiting

```json
{
  "error": "Rate limit exceeded",
  "retry_after": 60
}
```

**Solutions**:
- Wait for retry_after seconds
- Implement exponential backoff
- Reduce request frequency

## 🔧 API Testing

### Using Swagger UI

1. **Open the schema file** in a text editor
2. **Copy the YAML content**
3. **Go to [Swagger UI](https://editor.swagger.io/)**
4. **Paste the YAML content**
5. **Test the API endpoints**

### Using Postman

1. **Import the schema file** into Postman
2. **Set up environment variables**:
   - `base_url`: `https://api.example.com/`
   - `oauth_url`: `https://api.example.com/`
   - `client_id`: Your client ID
   - `client_secret`: Your client secret

3. **Create a collection** with the endpoints
4. **Test authentication and API calls**

### Using cURL

```bash
# Get OAuth token
TOKEN=$(curl -s -X POST "https://api.example.com/" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -H "Authorization: Basic $(echo -n 'client_id:client_secret' | base64)" \
  -d "grant_type=client_credentials&scope=tdxticket" | jq -r '.access_token')

# Create ticket
curl -X POST "https://api.example.com//tickets" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "appId": 31,
    "typeId": 12,
    "statusId": 77,
    "sourceId": 8,
    "serviceId": 67,
    "responsibleGroupId": 631,
    "title": "[Feedback] Test ticket",
    "description": "Test feedback message"
  }'
```

## 📊 Rate Limiting

### Limits

- **OAuth Token Requests**: 100 requests per hour
- **API Requests**: 1000 requests per hour
- **Ticket Creation**: 100 tickets per hour

### Headers

```
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 999
X-RateLimit-Reset: 1642248000
```

### Handling Rate Limits

```ruby
# Implement exponential backoff
def handle_rate_limit(response)
  if response.code == 429
    retry_after = response.headers['Retry-After'].to_i
    sleep(retry_after)
    retry
  end
end
```

## 🔄 Keeping Schemas Updated

These schemas are provided by the University of Michigan API Directory team. To keep them current:

1. **Monitor for updates** from the official API documentation
2. **Update the YAML files** when new versions are released
3. **Test your integration** after schema updates
4. **Document any breaking changes** in your gem's changelog

## 🛠️ Schema Validation

You can use these OpenAPI schemas with tools like:

- **Swagger UI**: Visualize and test the APIs
- **OpenAPI Generator**: Generate client code in various languages
- **Postman**: Import and test API endpoints
- **API testing frameworks**: Validate responses against schemas

## 🔗 Related Documentation

- [TeamDynamix API Documentation](https://docs.google.com/document/d/14G-E5Zb2208cHcE5genW5mW0bVEEEtfCTH1N6erP0gA/edit?usp=sharing)
- [UMich API Postman Collections](https://drive.google.com/drive/folders/1OdXufmwJJ_Qy-uSJImlmZImCkN-RqBCE)
- [OpenAPI Specification](https://swagger.io/specification/)

## 🔄 Next Steps

Now that you understand the API schemas:

1. **[Configuration Guide](Configuration-Guide.md)** - Configure the gem with correct values
2. **[Testing Guide](Testing)** - Test your API integration
3. **[Production Deployment](Production-Deployment.md)** - Deploy with confidence
4. **[Troubleshooting Guide](Troubleshooting.md)** - Solve API-related issues

## 🆘 Need Help?

- Check the [Troubleshooting Guide](Troubleshooting.md)
- Review [Configuration Guide](Configuration-Guide.md) for setup details
- [Open an issue](https://github.com/lsa-mis/tdx-feedback_gem/issues) on GitHub

---

*For more details about specific API endpoints, refer to the YAML schema files in the `docs/` directory.*
