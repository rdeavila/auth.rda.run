# auth.rda.run

A containerized authentication service using
[pocket-id](https://github.com/pocket-id/pocket-id) with Cloudflare R2 storage
for persistent data.

## Features

- **Authentication Service**: Built on pocket-id for robust identity management
- **Cloud Storage**: Automatic synchronization with Cloudflare R2
- **Containerized**: Alpine Linux-based container for minimal footprint
- **Auto-sync**: Bidirectional data sync between local storage and R2

## Architecture

The service runs pocket-id with automatic R2 synchronization:

- Initial data pull from R2 on startup
- Continuous push to R2 every 5 minutes via cron
- Local data directory (`/app/data`) stays in sync with R2 bucket

## Quick Start

### Prerequisites

- Podman or Docker
- Cloudflare R2 bucket and API credentials
- MaxMind license key (optional, for geolocation features)

### Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `R2_ACCOUNT_ID` | Cloudflare account ID | Yes |
| `R2_ACCESS_KEY_ID` | R2 access key ID | Yes |
| `R2_SECRET_ACCESS_KEY` | R2 secret access key | Yes |
| `R2_BUCKET` | R2 bucket name | Yes |
| `APP_URL` | Public URL of the service | Yes |
| `MAXMIND_LICENSE_KEY` | MaxMind API key | No |
| `TRUST_PROXY` | Trust proxy headers | No |
| `PORT` | Service port (default: 1411) | No |
| `HOST` | Bind address (default: 0.0.0.0) | No |

### Run

```bash
podman build -t auth .
podman run -it --rm --name auth \
  -e R2_ACCOUNT_ID=your_account_id \
  -e R2_ACCESS_KEY_ID=your_key \
  -e R2_SECRET_ACCESS_KEY=your_secret \
  -e R2_BUCKET=bucket_name \
  -e APP_URL=https://pocket-id.domain.tld \
  -e MAXMIND_LICENSE_KE=your_maxmind_api_key \
  -e TRUST_PROXY=true \
  -e PORT=1411 \
  -e HOST=0.0.0.0 \
  -p 1411:1411 \
  auth
```
