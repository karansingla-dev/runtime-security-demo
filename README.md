# Runtime Security Demo with Falco

## Overview
This project demonstrates runtime security monitoring using Falco to detect:
1. Unauthorized file access (`/etc/passwd` reads)
2. Dangerous database queries (`SELECT *` on PII tables)

## Quick Start with Gitpod

[![Open in Gitpod](https://gitpod.io/button/open-in-gitpod.svg)](https://gitpod.io/#https://github.com/YOUR_USERNAME/runtime-security-demo)

## Architecture
- **API Service**: Python Flask application
- **Database**: PostgreSQL with PII data
- **Security**: Falco runtime security monitor with eBPF

## Setup Instructions

### Local Setup (Linux only)
```bash
docker-compose up -d
./test_demo.sh