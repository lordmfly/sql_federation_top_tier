
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
| Trino | <http://localhost:8080> |
| Metabase | <http://localhost:3000> |
| Grafana | <http://localhost:3001> |
| Prometheus | <http://localhost:9090> |
| Keycloak | <http://localhost:8081> |

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

## Switch environments

terraform workspace select dev
terraform workspace select test
terraform apply -var-file=environments/test/terraform.tfvars

terraform workspace select prod
terraform apply -var-file=environments/prod/terraform.tfvars

## Azure Mapping

Docker → AKS  
MinIO → ADLS  
Keycloak → Azure AD  

---
 Security Design
 Identity and Access Management (IAM)

The platform uses centralized identity via Microsoft Entra ID.

Design
All users and services authenticate through Entra ID
RBAC is enforced at:
AKS (cluster + namespace)
Trino (catalog/schema-level access)
Azure resources (via IAM roles)
Implementation
Use Managed Identities for:
AKS workloads accessing ADLS, databases, Key Vault
Map Entra ID groups → Trino roles
Why this matters
Eliminates credential sprawl
Enables centralized audit + governance

Authentication and Authorization
Authentication
OIDC-based authentication (Entra ID)
Trino integrates via:
OAuth2 / OIDC plugin
Tokens are validated at the gateway or Trino layer
Authorization
Multi-layer enforcement:
Trino → catalog/schema/table-level permissions
Azure → RBAC on resources
Kubernetes → RBAC + service accounts
Example
Data analyst → read-only access to analytics.*
Data engineer → write access to curated schemas

Secret Management
Tooling
Azure Key Vault
Approach
Store:
DB credentials
API tokens
TLS certificates
Access via:
Managed Identity (no hardcoded secrets)
Runtime Flow
Trino Pod → Managed Identity → Key Vault → Secret Injection
Best Practice
Rotate secrets automatically
Never store secrets in:
Git
Docker images
Config files

Network Isolation
Core Design
Fully private architecture using:
Azure Virtual Network
Subnets per tier:
AKS
Databases
Private endpoints
Controls
NSGs (Network Security Groups)
Private DNS zones
No direct internet exposure for data services
Result
East-west traffic controlled
No lateral movement risk
Private vs Public Exposure
Component Exposure
Application Gateway Public (WAF protected)
AKS API Private
Trino service Internal
Databases Private only
ADLS Private Endpoint
Pattern
Only ingress point is:
Application Gateway (WAF)
Everything else is:
Private + internal routing

Encryption
In Transit
TLS everywhere:
Client → Gateway
Gateway → AKS
Trino → data sources
At Rest
Azure-managed encryption:
ADLS
PostgreSQL/MySQL
Optional:
Customer-managed keys (CMK via Key Vault)
⚖️ Least-Privilege Principles
Enforcement
Minimal RBAC roles
Scoped identities per service
No shared credentials
Examples
Trino worker:
Read-only access to ADLS
CI/CD pipeline:
Deploy-only permissions
Analyst:
Query-only permissions
Outcome
Reduces blast radius
Limits insider risk

Data Platform Design
Azure-Hosted Relational Databases
Services
Azure Database for PostgreSQL
Azure Database for MySQL
Integration
Trino JDBC connectors:
connector.name=postgresql
connection-url=jdbc:postgresql://<private-endpoint>
Design Considerations
Use Private Endpoints
Optimize for:
Read-heavy queries
Connection pooling

Object Storage / Lakehouse
Service
Azure Data Lake Storage Gen2
Access Pattern
Trino Hive connector:
Supports Parquet, ORC, Iceberg
Benefits
Decoupled compute + storage
Scalable analytics

Metadata and Catalog
Current
Hive Metastore (self-managed or containerized)
Future (Enterprise)
Microsoft Purview
Role
Schema discovery
Data lineage
Governance + compliance
Deployment Model
Environment Strategy
Environments
dev
Rapid iteration
Lower cost
test/staging
Integration validation
Performance testing
prod
HA + SLA-backed
Isolation
Separate:
VNets
AKS clusters
Resource groups

Infrastructure as Code (IaC)
Tooling
Terraform
Approach
Modular design:
networking/
aks/
storage/
databases/
Benefits
Reproducibility
Version control
Drift detection

Release Process
CI/CD Flow
GitHub → CI (build/test)
        ↓
Terraform (infra)
        ↓
ArgoCD (deploy to AKS)
Tools
GitHub Actions
Argo CD
Strategy
Blue/green or canary deployments
Rollback via Git
Operational Ownership Model
Layer Owner
Infrastructure Platform Engineering
Kubernetes / AKS SRE
Trino Platform Data Platform Team
Data Sources Application Teams

Why This Model Works
Clear separation of responsibilities
Enables scaling teams independently
Aligns with real enterprise structures
