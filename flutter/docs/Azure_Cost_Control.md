# RiderMate 2.0 — Azure Cost Control & Student Credit Protection Plan

## 1. Credit Protection Strategy (Azure for Students)

The developer utilizes **Azure for Students** (USD $100 annual credit grant + monthly free allowances). To preserve this credit:

- **EXPECTED MONTHLY AZURE COST**: **As close to $0.00 as practical** (utilizing free grants).
- **Compute Model**: Serverless Azure Functions (Consumption Plan only).
- **Zero Idle Costs**: Compute scales to 0 instances when no requests are being processed.
- **Single Resource Group**: `rg-ridermate-dev` contains all development resources.

---

## 2. Resource Inventory & Cost Classification

| Azure Service | Provisioned SKU / Plan | Monthly Free Grant / Allowance | Expected Usage | Cost Risk Level |
|---|---|---|---|---|
| **Resource Group** (`rg-ridermate-dev`) | N/A | Free | N/A | None |
| **Azure Functions** (`func-ridermate-api`) | Consumption (Serverless Y1) | 1,000,000 requests & 400,000 GB-s/mo | ~5,000 requests/mo | **Zero ($0.00)** |
| **Storage Account** (`st-ridermate-functions`) | Standard LRS (Blob/Table) | Internal Function runtime files | < 50 MB storage | **Minimal (< $0.01)** |
| **Application Insights** (`appi-ridermate`) | Basic (Log Analytics) | 5 GB/month ingestion free | ~50 MB logs/mo | **Zero ($0.00)** |

---

## 3. Explicit Prohibited Paid Services

To protect student credits, the following high-cost Azure resources are **STRICTLY PROHIBITED**:

- ❌ **No Azure Virtual Machines (VMs)**
- ❌ **No Azure Kubernetes Service (AKS)**
- ❌ **No Dedicated App Service Plans (B1, S1, P1v2)**
- ❌ **No Azure SQL Databases**
- ❌ **No Azure Cosmos DB Provisioned Throughput**
- ❌ **No Azure Cache for Redis**
- ❌ **No Premium Functions (EP1, EP2)**
- ❌ **No Always-Ready / Pre-Warmed Function instances**
- ❌ **No Paid API Management (APIM) Tiers**
- ❌ **No Application Gateways / NAT Gateways / VPN Gateways**

---

## 4. Architectural Cost Controls

1. **Local-First Telemetry**: Real-time GPS points (emitted every 1 second) are stored and processed locally in SQLite. The mobile app **never** sends per-second GPS streams to Azure.
2. **Aggregated API Triggers**: Cloud Functions are triggered only upon explicit user actions (e.g. completing a ride or requesting AI safety analysis).
3. **Client-Side Cooldowns**: `AzureApiClient` enforces rate-limiting and request throttling to prevent accidental loop executions.
4. **Log Verbosity Suppression**: Application Insights logging is restricted to warning/error categories to prevent log ingestion charges.
