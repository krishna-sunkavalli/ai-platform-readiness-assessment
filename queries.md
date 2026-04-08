# AIRA - Query Reference

All queries executed by the AI Platform Readiness Assessment workbook. 35 are automated Azure Resource Graph (ARG) queries; 2 require manual/API verification.

## Data Management & Governance

| Query ID | Query Name | Type | Function |
|----------|-----------|------|----------|
| DMG-001 | Purview Accounts | ARG | Lists Microsoft Purview accounts for unified data governance |
| DMG-002 | Purview Scan Rulesets | ARG | Validates scan rulesets are configured for data discovery |
| DMG-003 | Data Classification Rules | ARG | Checks for cloud connector configurations enabling data classification |
| DMG-004 | Data Lineage Enablement | ARG | Verifies lineage endpoints are configured for tracking data flow |
| DMG-005 | Unity Catalog | ARG | Lists Azure Databricks workspaces for unified analytics governance |
| DMG-006 | ADF ETL Coverage | ARG | Lists Data Factory instances with Git integration and global parameters |
| DMG-007 | Lakehouse Presence | ARG | Detects ADLS Gen2, Databricks, or Microsoft Fabric for enterprise data lake |
| DMG-008 | Retention & Lifecycle Policies | ARG | Checks ADLS Gen2 lifecycle management policies |

## Retrieval & Context Enablement

| Query ID | Query Name | Type | Function |
|----------|-----------|------|----------|
| RCE-001 | AI Search | ARG | Lists AI Search services with SKU, semantic search, vector capability, and replica/partition counts |
| RCE-002 | Redis Cache | ARG | Lists Azure Cache for Redis instances for semantic and response caching |
| RCE-003 | Cosmos DB / PostgreSQL | ARG | Lists vector-capable databases (Cosmos DB, PostgreSQL Flexible) for RAG patterns |
| RCE-004 | Vector Stores | ARG | Aggregates all vector-capable stores: AI Search, Cosmos DB (vector), PostgreSQL (pgvector) |
| RCE-005 | Document Intelligence | ARG | Lists Azure AI Document Intelligence accounts for OCR and document processing |

## Model Management

| Query ID | Query Name | Type | Function |
|----------|-----------|------|----------|
| MDL-001 | Azure OpenAI / AI Services | ARG | Lists core model hosting services with auth, networking, and private endpoint status |
| MDL-002 | ML Workspaces | ARG | Lists Azure ML workspaces with MLflow tracking, identity, and App Insights config |
| MDL-003 | GPU Compute | ARG | Summarizes GPU resources (NC/ND/NV series) for model training and inference |
| MDL-004 | AI Foundry Projects | ARG | Lists AI Foundry projects with identity and endpoint configuration |
| MDL-005 | Online Endpoints | ARG | Lists real-time model serving endpoints with auth mode and provisioning state |
| MDL-006 | Model Deployments | ARG | Lists deployed models on Azure OpenAI/AI Services with model name, version, and capacity type |
| MDL-007 | Fine-Tuned Models | ARG | Detects custom fine-tuned model deployments |
| MDL-008 | AI Foundry Evaluation Runs | ARG | Checks AI Foundry projects for evaluation capabilities |

## Responsible AI

| Query ID | Query Name | Type | Function |
|----------|-----------|------|----------|
| RAI-001 | Content Safety | ARG | Lists dedicated Content Safety service instances |
| RAI-002 | Content Filtering Enabled | ARG | Checks if Azure OpenAI/AI Services accounts have content safety filtering (RaiMonitor) enabled |
| RAI-003 | Red Teaming Runs | Manual/API | Check AI Foundry portal or API for completed red teaming runs and Attack Success Rate (ASR) metrics |
| RAI-004 | Content Safety Feature Matrix | ARG | Maps content safety capabilities (Jailbreak Detection, Prompt Shield, Protected Material, Groundedness Detection, Text/Image Moderation, RAI Policies, Content Provenance, Agent Safety, Custom Categories) per AI account |

## Security & Compliance

| Query ID | Query Name | Type | Function |
|----------|-----------|------|----------|
| SEC-001 | Managed Identities | ARG | Summarizes managed identity adoption across Cognitive Services, ML Workspaces, and AI Search |
| SEC-002 | Key Vault | ARG | Lists Key Vaults with soft delete, purge protection, and RBAC authorization status |
| SEC-003 | Private Networking & PE State | ARG | Reports public network access and private endpoint connection state for AI resources |
| SEC-004 | Defender for Cloud | ARG | Shows Defender pricing tier for CloudPosture, Containers, VMs, Storage, and API plans |
| SEC-005 | Defender for AI Services | ARG | Shows Defender pricing tier for the AI plan specifically |
| SEC-006 | Model API Authentication | ARG | Summarizes local auth disabled and public access disabled counts across AI Services |
| SEC-007 | APIM as AI Gateway | ARG | Lists API Management instances for centralized AI API access control |

## Monitoring & Operations

| Query ID | Query Name | Type | Function |
|----------|-----------|------|----------|
| MON-001 | Application Insights | ARG | Lists Application Insights instances for AI application APM |
| MON-002 | AI Services Diagnostics | ARG | Reports diagnostic settings coverage for Cognitive Services and ML Workspaces |
| MON-003 | Metric Alert Rules | ARG | Lists metric alert rules targeting Cognitive Services resources |
| MON-004 | Log Analytics Workspace Coverage | ARG | Reports how many AI resources route diagnostics to a Log Analytics workspace |
| MON-005 | Quality Evaluators | Manual/API | Check AI Foundry portal or API for groundedness, relevance, coherence, fluency evaluators |
