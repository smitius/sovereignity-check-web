# Digital Sovereignty Readiness Assessment

> **Self-Contained Containerized Version**
>
> This is a self-standing, containerized fork of the Red Hat Digital Sovereignty Readiness Assessment tool. Built for easy deployment with all dependencies included.

## Overview

A streamlined assessment tool that helps organizations evaluate their digital sovereignty readiness across **7 critical domains** in just **10-15 minutes**.

- **Quick Assessment**: 21 targeted questions
- **4-Level Maturity Model**: Foundation → Developing → Strategic → Advanced
- **PDF Reports**: Downloadable stakeholder reports
- **Privacy-First**: No data leaves your infrastructure
- **Self-Contained**: All dependencies included, no external calls during build

## Quick Start

### Docker (Recommended)

```bash
# Clone the repository
git clone git@github.com:smitius/sovereignity-check-web.git
cd sovereignity-check-web

# Build and run
docker build -t sovereign-check:latest .
docker run -d -p 8080:8080 --name sovereign-check sovereign-check:latest

# Access
open http://localhost:8080
```

### Docker Compose

```bash
# One-command deployment
docker-compose up -d --build

# Access
open http://localhost:8080
```

## Deployment Options

### 1. Local Development

```bash
git clone git@github.com:smitius/sovereignity-check-web.git
cd sovereignity-check-web
docker-compose up -d --build
```

### 2. Remote Server (Portainer)

1. Log into Portainer
2. Navigate to **Stacks** → **Add Stack**
3. Name: `sovereign-check`
4. Build method: **Repository**
5. Repository URL: `https://github.com/smitius/sovereignity-check-web`
6. Repository reference: `refs/heads/master`
7. Deploy

### 3. Manual Server Deployment

```bash
# On target server
git clone git@github.com:smitius/sovereignity-check-web.git
cd sovereignity-check-web
docker build -t sovereign-check:latest .
docker run -d \
  --name sovereign-check \
  -p 8080:8080 \
  --restart unless-stopped \
  sovereign-check:latest
```

### 4. Behind Reverse Proxy (Nginx Proxy Manager)

```yaml
# docker-compose.override.yml
version: "3.8"
services:
  sovereign-check:
    ports:
      - "8080"  # Internal port only
    networks:
      - default
      - proxy

networks:
  proxy:
    external: true
```

Then configure NPM:
- Domain: `sovereign.yourdomain.com`
- Forward Host: `sovereign-check`
- Forward Port: `8080`

## Build Details

### Self-Contained Design

This repository includes everything needed to build without external dependencies:

| Component | Included | Purpose |
|-----------|----------|---------|
| `vendor/` | ✅ | All PHP dependencies (dompdf, monolog, etc.) |
| `composer.lock` | ✅ | Locked dependency versions |
| `Dockerfile` | ✅ | UBI9 PHP 8.3 base image |
| Fonts | ✅ | Red Hat Display & Text fonts |
| Static assets | ✅ | CSS, JS, images |

### Base Image

- **Image**: `registry.access.redhat.com/ubi9/php-83:latest`
- **Platform**: Multi-arch (amd64, arm64)
- **Size**: ~200MB
- **User**: Non-root (1001)

### Container Configuration

```dockerfile
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
    CMD curl -f http://localhost:8080/ || exit 1
USER 1001
```

## Architecture

```
┌─────────────────────────────────────┐
│          User Browser               │
└─────────────┬───────────────────────┘
              │
┌─────────────▼───────────────────────┐
│      Reverse Proxy (optional)       │
│    Nginx Proxy Manager / Traefik    │
└─────────────┬───────────────────────┘
              │
┌─────────────▼───────────────────────┐
│   sovereign-check container         │
│   ┌─────────────────────────────┐   │
│   │  PHP 8.3 Built-in Server    │   │
│   │  Port: 8080                 │   │
│   └─────────────────────────────┘   │
└─────────────────────────────────────┘
```

## Features

### Assessment
- **7 Domains**: Data, Technical, Operational, Assurance, Open Source, Executive, Managed Services
- **21 Questions**: Targeted, multiple-choice format
- **Auto-Save**: Progress persists in browser storage
- **PDF Export**: Professional reports via dompdf

### Security
- Client-side only (no data submission)
- No external tracking or analytics
- CSRF protection
- Input validation
- Secure headers (X-Frame-Options, etc.)

### UI/UX
- Red Hat PatternFly design system
- Responsive layout
- Keyboard navigation
- Accessibility compliant

## Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `PHP_MEMORY_LIMIT` | `256M` | PDF generation memory |
| `PHP_MAX_EXECUTION_TIME` | `30` | Script timeout |

### Custom Questions

Edit `ds-qualifier/config.php` to modify:
- Domain definitions
- Question text
- Help tooltips

## Development

### Local Changes

```bash
# Make changes
echo "<!-- Custom HTML -->" >> index.php

# Rebuild
docker-compose up -d --build

# Test
curl http://localhost:8080
```

### Add Dependencies

```bash
# Add new package
composer require vendor/package

# Update lock file
composer update --lock

# Commit vendor changes
git add vendor/ composer.lock
git commit -m "Add dependency: vendor/package"
```

## Troubleshooting

### Container won't start

```bash
# Check logs
docker logs sovereign-check

# Verify health
docker inspect sovereign-check | jq '.[0].State.Health'
```

### PDF generation fails

```bash
# Check memory limits
docker exec sovereign-check php -r "echo ini_get('memory_limit');"

# Increase if needed
# Edit Dockerfile: ENV PHP_MEMORY_LIMIT=512M
```

### Permission denied

```bash
# Fix ownership (shouldn't happen with UBI base)
docker exec sovereign-check ls -la /opt/app-root/src/
```

## File Structure

```
sovereignity-check-web/
├── index.php                 # Landing page
├── composer.json             # Dependencies manifest
├── composer.lock             # Locked versions
├── Dockerfile                # Container build
├── docker-compose.yml        # Compose stack
├── .dockerignore             # Build exclusions
├── .gitignore                # Git exclusions
│
├── ds-qualifier/             # Assessment module
│   ├── index.php            # Questionnaire
│   ├── results.php          # Results page
│   ├── generate-pdf.php     # PDF generator
│   └── config.php           # Questions config
│
├── includes/                 # Core classes
│   ├── Config.php
│   ├── Security.php
│   └── Logger.php
│
├── css/                      # Stylesheets
├── js/                       # JavaScript
│   └── ds-qualifier.js      # Interactive features
├── images/                   # Assets
│   └── evroc_logo*.png      # Custom branding
│
└── vendor/                   # PHP dependencies
    ├── dompdf/              # PDF generation
    ├── monolog/             # Logging
    └── ...
```

## Upstream

This project is based on [Red Hat viewfinder-upstream](https://github.com/redhat-cop/viewfinder-upstream), modified for:
- Self-contained deployment
- Container-first architecture
- Custom branding (evroc)
- Streamlined build process

## License

Apache-2.0 - See [LICENSE](LICENSE)

## Support

For issues or feature requests:
- GitHub Issues: https://github.com/smitius/sovereignity-check-web/issues

---

**Built for evroc** · Self-hosted · Privacy-first
