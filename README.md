# FXBridge – Multi-Source Rate Aggregator API

Aggregates live forex and crypto exchange rates from multiple providers (Binance, ExchangeRate.host, etc.), returning the best conversion paths for remittance and arbitrage use cases.

## Features

- 🔄 **Multi-Source Aggregation**: Fetches rates from Binance (crypto), ExchangeRate.host (fiat), and Fixer.io (optional)
- 💰 **Arbitrage Detection**: Calculates arbitrage opportunities across different providers
- ⚡ **Caching**: In-memory caching with configurable TTL to reduce API calls
- 📊 **Best Rate Selection**: Automatically identifies the provider with the best rate
- 📝 **Request Logging**: Middleware for logging all API requests
- 📚 **Swagger Documentation**: OpenAPI 3.0 specification with interactive UI
- 📬 **Postman Collection**: Ready-to-use Postman collection included

## Project Structure

```
fxbridge-aggregator/
├── bin/
│   └── main.dart              # Application entry point
├── lib/
│   ├── routes/
│   │   └── routes.dart       # API route definitions
│   ├── services/
│   │   ├── exchange_provider.dart    # Exchange rate providers
│   │   ├── arbitrage_service.dart   # Arbitrage calculations
│   │   ├── cache_service.dart       # Caching layer
│   │   └── rate_aggregator_service.dart  # Main aggregation service
│   ├── middleware/
│   │   └── request_logger.dart      # Request logging middleware
│   └── utils/
│       └── config.dart              # Configuration management
├── test/                      # Unit tests
├── pubspec.yaml              # Dart dependencies
├── README.md                 # This file
├── .env.example             # Environment variables template
└── Dockerfile               # Docker configuration
```

## Prerequisites

- Dart SDK >= 3.0.0
- Docker (optional, for containerized deployment)

## Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd fxbridge-aggregator
```

2. Install dependencies:
```bash
dart pub get
```

3. Copy environment variables:
```bash
cp .env.example .env
```

4. (Optional) Edit `.env` to add API keys:
```env
FIXER_API_KEY=your_fixer_api_key_here
CACHE_TTL_SECONDS=60
PORT=8080
```

## Running the Application

### Local Development

```bash
dart run bin/main.dart
```

The server will start on `http://localhost:8080` (or the port specified in `.env`).

### Docker

```bash
# Build the image
docker build -t fxbridge-aggregator .

# Run the container
docker run -p 8080:8080 --env-file .env fxbridge-aggregator
```

## API Endpoints

### GET `/health`

Health check endpoint.

**Response:**
```json
{
  "status": "healthy",
  "timestamp": "2024-01-01T00:00:00.000Z"
}
```

### GET `/rates`

Get aggregated exchange rates from multiple providers.

**Query Parameters:**
- `base` (optional): Base currency code (default: `USD`)
- `target` (required): Target currency code

**Example Request:**
```bash
curl "http://localhost:8080/rates?base=USD&target=EUR"
```

**Example Response:**
```json
{
  "timestamp": "2024-01-01T12:00:00.000Z",
  "base": "USD",
  "target": "EUR",
  "sources": {
    "ExchangeRate.host": 0.92,
    "Fixer.io": 0.921
  },
  "bestRate": 0.921,
  "bestProvider": "Fixer.io",
  "arbitrageOpportunity": "0.11"
}
```

**Response Fields:**
- `timestamp`: ISO 8601 timestamp of when the rate was fetched
- `base`: Base currency code
- `target`: Target currency code
- `sources`: Map of provider names to their rates
- `bestRate`: Highest rate available (best for selling base currency)
- `bestProvider`: Provider offering the best rate
- `arbitrageOpportunity`: Percentage difference between highest and lowest rates (only shown when multiple sources available)

### GET `/swagger.json`

OpenAPI 3.0 specification in JSON format.

### GET `/swagger`

Interactive Swagger UI for exploring the API.

## Postman Collection

A Postman collection (`postman_collection.json`) is included in the project root. Import it into Postman to quickly test all endpoints with pre-configured requests.

## Supported Currency Pairs

- **Forex**: USD, EUR, GBP, JPY, AUD, CAD, CHF, CNY, and more (via ExchangeRate.host and Fixer.io)
- **Crypto**: BTC, ETH, USDT, and other pairs supported by Binance

## Testing

Run unit tests:

```bash
dart test
```

Test coverage includes:
- Cache service functionality
- Arbitrage calculation logic
- Exchange provider integrations
- Rate aggregation service

## Configuration

Environment variables (`.env`):

| Variable | Description | Default |
|----------|-------------|---------|
| `PORT` | Server port | `8080` |
| `HOST` | Server host | `0.0.0.0` |
| `CACHE_TTL_SECONDS` | Cache time-to-live in seconds | `60` |
| `LOG_LEVEL` | Logging level | `info` |
| `BINANCE_API_KEY` | Binance API key (optional) | - |
| `EXCHANGERATE_API_KEY` | ExchangeRate.host API key (optional) | - |
| `FIXER_API_KEY` | Fixer.io API key (optional) | - |

## Example Usage

### Get USD to EUR rate:
```bash
curl "http://localhost:8080/rates?base=USD&target=EUR"
```

### Get BTC to USDT rate (crypto):
```bash
curl "http://localhost:8080/rates?base=BTC&target=USDT"
```

### Get GBP to JPY rate:
```bash
curl "http://localhost:8080/rates?base=GBP&target=JPY"
```

## Architecture

- **Exchange Providers**: Abstract interface for different rate sources (Binance, ExchangeRate.host, Fixer.io)
- **Arbitrage Service**: Calculates best rates and arbitrage opportunities
- **Cache Service**: In-memory caching with TTL support
- **Rate Aggregator**: Orchestrates fetching from multiple providers and aggregating results
- **Middleware**: Request logging for monitoring and debugging

## Error Handling

The API handles errors gracefully:
- Missing required parameters return `400 Bad Request`
- Provider failures are logged but don't stop aggregation (if other providers succeed)
- No rates available returns `500 Internal Server Error` with error message

## License

MIT License

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

