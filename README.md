
# SQL Federation Platform 

## Overview
Production-grade SQL federation platform using Trino with:
- Multi-source federation (Postgres + MySQL + S3/MinIO)
- Metabase UI
- Prometheus + Grafana observability
- Keycloak SSO (OIDC)
- Azure-ready architecture (AKS, ADLS, Key Vault)

---

## Quick Start

cd docker
docker compose up -d

---

## Services

| Service | URL |
|--------|-----|
| Trino | http://localhost:8080 |
| Metabase | http://localhost:3000 |
| Grafana | http://localhost:3001 |
| Prometheus | http://localhost:9090 |
| Keycloak | http://localhost:8081 |

---

## Example Query

SELECT o.order_id, o.amount, c.customer_name
FROM postgresql.public.orders o
JOIN mysql.crm.customers c
ON o.customer_id = c.id;

---

## Validation

- docker compose up runs cleanly
- All services reachable
- Queries execute successfully
- No critical logs

---

## Architecture

See diagrams/architecture.png

---

## Azure Mapping

Docker → AKS  
MinIO → ADLS  
Keycloak → Azure AD  

---

## Future Enhancements

- Iceberg support
- Multi-region failover
- Query caching