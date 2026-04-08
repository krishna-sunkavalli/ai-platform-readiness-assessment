# AIRA - Query Reference

All queries executed by the AI Platform Readiness Assessment workbook. 35 are automated Azure Resource Graph (ARG) queries; 2 require manual/API verification.

## Summary

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
| RCE-001 | AI Search | ARG | Lists AI Search services with SKU, semantic search, vector capability, and replica/partition counts |
| RCE-002 | Redis Cache | ARG | Lists Azure Cache for Redis instances for semantic and response caching |
| RCE-003 | Cosmos DB / PostgreSQL | ARG | Lists vector-capable databases (Cosmos DB, PostgreSQL Flexible) for RAG patterns |
| RCE-004 | Vector Stores | ARG | Aggregates all vector-capable stores: AI Search, Cosmos DB (vector), PostgreSQL (pgvector) |
| RCE-005 | Document Intelligence | ARG | Lists Azure AI Document Intelligence accounts for OCR and document processing |
| MDL-001 | Azure OpenAI / AI Services | ARG | Lists core model hosting services with auth, networking, and private endpoint status |
| MDL-002 | ML Workspaces | ARG | Lists Azure ML workspaces with MLflow tracking, identity, and App Insights config |
| MDL-003 | GPU Compute | ARG | Summarizes GPU resources (NC/ND/NV series) for model training and inference |
| MDL-004 | AI Foundry Projects | ARG | Lists AI Foundry projects with identity and endpoint configuration |
| MDL-005 | Online Endpoints | ARG | Lists real-time model serving endpoints with auth mode and provisioning state |
| MDL-006 | Model Deployments | ARG | Lists deployed models on Azure OpenAI/AI Services with model name, version, and capacity type |
| MDL-007 | Fine-Tuned Models | ARG | Detects custom fine-tuned model deployments |
| MDL-008 | AI Foundry Evaluation Runs | ARG | Checks AI Foundry projects for evaluation capabilities |
| RAI-001 | Content Safety | ARG | Lists dedicated Content Safety service instances |
| RAI-002 | Content Filtering Enabled | ARG | Checks if Azure OpenAI/AI Services accounts have content safety filtering (RaiMonitor) enabled |
| RAI-003 | Red Teaming Runs | Manual/API | Check AI Foundry portal or API for completed red teaming runs and ASR metrics |
| RAI-004 | Content Safety Feature Matrix | ARG | Maps content safety capabilities per AI account |
| SEC-001 | Managed Identities | ARG | Summarizes managed identity adoption across Cognitive Services, ML Workspaces, and AI Search |
| SEC-002 | Key Vault | ARG | Lists Key Vaults with soft delete, purge protection, and RBAC authorization status |
| SEC-003 | Private Networking & PE State | ARG | Reports public network access and private endpoint connection state for AI resources |
| SEC-004 | Defender for Cloud | ARG | Shows Defender pricing tier for CloudPosture, Containers, VMs, Storage, and API plans |
| SEC-005 | Defender for AI Services | ARG | Shows Defender pricing tier for the AI plan specifically |
| SEC-006 | Model API Authentication | ARG | Summarizes local auth disabled and public access disabled counts across AI Services |
| SEC-007 | APIM as AI Gateway | ARG | Lists API Management instances for centralized AI API access control |
| MON-001 | Application Insights | ARG | Lists Application Insights instances for AI application APM |
| MON-002 | AI Services Diagnostics | ARG | Reports diagnostic settings coverage for Cognitive Services and ML Workspaces |
| MON-003 | Metric Alert Rules | ARG | Lists metric alert rules targeting Cognitive Services resources |
| MON-004 | Log Analytics Workspace Coverage | ARG | Reports how many AI resources route diagnostics to a Log Analytics workspace |
| MON-005 | Quality Evaluators | Manual/API | Check AI Foundry portal or API for groundedness, relevance, coherence, fluency evaluators |

---

## Data Management & Governance

### DMG-001 -- Purview Accounts

**Function:** Lists Microsoft Purview accounts for unified data governance

```kql
resources
| where type == 'microsoft.purview/accounts'
| project name, location, subscriptionId, properties
```

### DMG-002 -- Purview Scan Rulesets

**Function:** Validates scan rulesets are configured for data discovery

```kql
resources
| where type == 'microsoft.purview/accounts'
| where isnotnull(properties.scanRulesets)
| project name, location, subscriptionId, scanRulesets=properties.scanRulesets
```

### DMG-003 -- Data Classification Rules

**Function:** Checks for cloud connector configurations enabling data classification

```kql
resources
| where type == 'microsoft.purview/accounts'
| where isnotnull(properties.cloudConnectors)
| project name, location, subscriptionId, properties
```

### DMG-004 -- Data Lineage Enablement

**Function:** Verifies lineage endpoints are configured for tracking data flow

```kql
resources
| where type == 'microsoft.purview/accounts'
| extend lineageEndpoint = tostring(properties.endpoints.lineage)
| where isnotnull(lineageEndpoint)
| project name, lineageEndpoint, location, subscriptionId
```

### DMG-005 -- Unity Catalog

**Function:** Lists Azure Databricks workspaces for unified analytics governance

```kql
resources
| where type == 'microsoft.databricks/workspaces'
| extend unityCatalog = properties.parameters.enableNoPublicIp
| project name, location, subscriptionId, properties
```

### DMG-006 -- ADF ETL Coverage

**Function:** Lists Data Factory instances with Git integration and global parameters

```kql
resources
| where type == 'microsoft.datafactory/factories'
| extend gitConfigured = isnotnull(properties.repoConfiguration.repositoryName),
         globalParams = array_length(bag_keys(properties.globalParameters))
| project name, location, subscriptionId, gitConfigured, globalParams
```

### DMG-007 -- Lakehouse Presence

**Function:** Detects ADLS Gen2, Databricks, or Microsoft Fabric for enterprise data lake

```kql
resources
| where type in (
    'microsoft.storage/storageaccounts',
    'microsoft.databricks/workspaces',
    'microsoft.fabric/capacities'
  )
| extend layer = case(
    type == 'microsoft.storage/storageaccounts' and properties.isHnsEnabled == true, 'ADLS Gen2',
    type == 'microsoft.databricks/workspaces', 'Databricks',
    type == 'microsoft.fabric/capacities', 'Microsoft Fabric',
    'Other'
  )
| where layer != 'Other'
| project name, layer, location, subscriptionId
```

### DMG-008 -- Retention & Lifecycle Policies

**Function:** Checks ADLS Gen2 lifecycle management policies

```kql
resources
| where type == 'microsoft.storage/storageaccounts'
| where kind == 'StorageV2' and properties.isHnsEnabled == true
| extend lifecyclePolicy = isnotnull(properties.managementPolicies)
| project name, location, subscriptionId, lifecyclePolicy
```

---

## Retrieval & Context Enablement

### RCE-001 -- AI Search

**Function:** Lists AI Search services with SKU, semantic search, vector capability, and replica/partition counts

```kql
resources
| where type == 'microsoft.search/searchservices'
| extend sku = tostring(sku.name),
         semanticSearch = tostring(properties.semanticSearch),
         replicaCount = toint(properties.replicaCount),
         partitionCount = toint(properties.partitionCount),
         publicAccess = properties.publicNetworkAccess,
         status = tostring(properties.status),
         provisioningState = tostring(properties.provisioningState),
         vectorCapable = tostring(sku.name) in ('standard','standard2','standard3','storage_optimized_l1','storage_optimized_l2')
| project name, sku, semanticSearch, vectorCapable, replicaCount, partitionCount, publicAccess, status, provisioningState, subscriptionId
```

### RCE-002 -- Redis Cache

**Function:** Lists Azure Cache for Redis instances for semantic and response caching

```kql
resources
| where type == 'microsoft.cache/redis' or type == 'microsoft.cache/redisenterprise'
| extend sku = tostring(sku.name),
         capacity = toint(sku.capacity)
| project name, sku, capacity, location, subscriptionId
```

### RCE-003 -- Cosmos DB / PostgreSQL

**Function:** Lists vector-capable databases (Cosmos DB, PostgreSQL Flexible) for RAG patterns

```kql
resources
| where type == 'microsoft.documentdb/databaseaccounts'
    or (type == 'microsoft.dbforpostgresql/flexibleservers')
| extend dbKind = case(
    type == 'microsoft.documentdb/databaseaccounts', 'Cosmos DB',
    type == 'microsoft.dbforpostgresql/flexibleservers', 'PostgreSQL Flexible',
    'Other'
  )
| extend vectorSearch = properties.capabilities has 'EnableNoSQLVectorSearch'
| project name, dbKind, vectorSearch, location, subscriptionId
```

### RCE-004 -- Vector Stores

**Function:** Aggregates all vector-capable stores: AI Search, Cosmos DB (vector), PostgreSQL (pgvector)

```kql
resources
| where type == 'microsoft.search/searchservices'
    or (type == 'microsoft.documentdb/databaseaccounts' and properties.capabilities has 'EnableNoSQLVectorSearch')
    or (type == 'microsoft.dbforpostgresql/flexibleservers')
| extend storeType = case(
    type == 'microsoft.search/searchservices', 'AI Search',
    type == 'microsoft.documentdb/databaseaccounts', 'Cosmos DB (vector)',
    type == 'microsoft.dbforpostgresql/flexibleservers', 'PostgreSQL (pgvector)',
    'Other'
  )
| project name, storeType, location, subscriptionId
```

### RCE-005 -- Document Intelligence

**Function:** Lists Azure AI Document Intelligence accounts for OCR and document processing

```kql
resources
| where type == 'microsoft.cognitiveservices/accounts'
| where kind == 'FormRecognizer' or kind == 'DocumentIntelligence'
| extend sku = tostring(sku.name),
         publicAccess = properties.publicNetworkAccess
| project name, kind, sku, publicAccess, location, subscriptionId
```

---

## Model Management

### MDL-001 -- Azure OpenAI / AI Services

**Function:** Lists core model hosting services with auth, networking, and private endpoint status

```kql
resources
| where type == 'microsoft.cognitiveservices/accounts'
| where kind in ('OpenAI', 'AIServices')
| extend sku = tostring(sku.name),
         publicAccess = properties.publicNetworkAccess,
         disableLocalAuth = properties.disableLocalAuth,
         privateEndpoints = array_length(properties.privateEndpointConnections)
| project name, kind, sku, publicAccess, disableLocalAuth, privateEndpoints, location, subscriptionId
```

### MDL-002 -- ML Workspaces

**Function:** Lists Azure ML workspaces with MLflow tracking, identity, and App Insights config

```kql
resources
| where type == 'microsoft.machinelearningservices/workspaces'
| extend mlflow = properties.mlFlowTrackingUri,
         publicAccess = properties.publicNetworkAccess,
         hbiWorkspace = properties.hbiWorkspace,
         appInsights = isnotnull(properties.applicationInsights),
         identity = identity.type
| project name, mlflow, publicAccess, hbiWorkspace, appInsights, identity, subscriptionId
```

### MDL-003 -- GPU Compute

**Function:** Summarizes GPU resources (NC/ND/NV series) for model training and inference

```kql
resources
| where type in ('microsoft.machinelearningservices/workspaces/computes', 'microsoft.compute/virtualmachines')
| extend vmSize = coalesce(properties.properties.vmSize, tostring(properties.hardwareProfile.vmSize))
| where vmSize contains 'NC' or vmSize contains 'ND' or vmSize contains 'NV'
| summarize count() by vmSize
```

### MDL-004 -- AI Foundry Projects

**Function:** Lists AI Foundry projects with identity and endpoint configuration

```kql
resources
| where type =~ 'microsoft.cognitiveservices/accounts/projects'
| extend hasIdentity = isnotnull(identity.principalId),
         endpoint = tostring(properties.endpoints)
| project name, location, hasIdentity, endpoint, subscriptionId
```

### MDL-005 -- Online Endpoints

**Function:** Lists real-time model serving endpoints with auth mode and provisioning state

```kql
resources
| where type == 'microsoft.machinelearningservices/workspaces/onlineendpoints'
| extend authMode = tostring(properties.authMode),
         provisioningState = tostring(properties.provisioningState)
| project name, location, authMode, provisioningState, subscriptionId
```

### MDL-006 -- Model Deployments

**Function:** Lists deployed models on Azure OpenAI/AI Services with model name, version, and capacity type

```kql
resources
| where type == 'microsoft.cognitiveservices/accounts/deployments'
| extend modelName = tostring(properties.model.name),
         modelVersion = tostring(properties.model.version),
         capacityType = tostring(properties.sku.name),
         provisioningState = tostring(properties.provisioningState)
| project name, modelName, modelVersion, capacityType, provisioningState, subscriptionId
```

### MDL-007 -- Fine-Tuned Models

**Function:** Detects custom fine-tuned model deployments

```kql
resources
| where type == 'microsoft.cognitiveservices/accounts/deployments'
| where properties.model.source contains 'fine-tun'
    or properties.model.format =~ 'custom'
| extend modelName = tostring(properties.model.name),
         modelVersion = tostring(properties.model.version)
| project name, modelName, modelVersion, location, subscriptionId
```

### MDL-008 -- AI Foundry Evaluation Runs

**Function:** Checks AI Foundry projects for evaluation capabilities

```kql
resources
| where type =~ 'microsoft.cognitiveservices/accounts/projects'
| extend hasEvals = isnotnull(properties.evaluations)
| project name, location, hasEvals, subscriptionId
```

---

## Responsible AI

### RAI-001 -- Content Safety

**Function:** Lists dedicated Content Safety service instances

```kql
resources
| where type =~ 'microsoft.cognitiveservices/accounts'
| where kind =~ 'ContentSafety'
| project name, location, resourceGroup, subscriptionId, kind, properties
```

### RAI-002 -- Content Filtering Enabled

**Function:** Checks if Azure OpenAI/AI Services accounts have content safety filtering (RaiMonitor) enabled

```kql
resources
| where type =~ 'microsoft.cognitiveservices/accounts'
| where kind in~ ('OpenAI', 'AIServices')
| extend caps = properties.capabilities
| mv-expand cap = caps
| where tostring(cap.name) == 'RaiMonitor'
| project name, kind, resourceGroup, subscriptionId, contentFilterEnabled = 'Yes'
```

### RAI-003 -- Red Teaming Runs

**Type:** Manual/API

Check AI Foundry portal or API for completed red teaming runs and Attack Success Rate (ASR) metrics.

```
GET https://{account}.services.ai.azure.com/api/projects/{project}/redteams/runs
```

### RAI-004 -- Content Safety Feature Matrix

**Function:** Maps content safety capabilities per AI account

```kql
resources
| where type =~ 'microsoft.cognitiveservices/accounts'
| where kind in~ ('OpenAI','AIServices','ContentSafety')
| extend rules = properties.callRateLimit.rules
| mv-expand rule = rules
| extend ruleKey = tostring(rule.key)
| where ruleKey in (
    'ContentSafety.TextJailbreak',
    'ContentSafety.TextShieldPrompt',
    'ContentSafety.TextProtectedMaterial',
    'ContentSafety.TextGroundedDetection',
    'ContentSafety.Text',
    'ContentSafety.Image',
    'ContentSafety.RaiPoliciesAPI',
    'ContentSafety.Provenance.Detect',
    'ContentSafety.AgentTaskAdherence',
    'ContentSafety.TextCustomCategories'
  )
| extend feature = case(
    ruleKey == 'ContentSafety.TextJailbreak', 'Jailbreak Detection',
    ruleKey == 'ContentSafety.TextShieldPrompt', 'Prompt Shield',
    ruleKey == 'ContentSafety.TextProtectedMaterial', 'Protected Material',
    ruleKey == 'ContentSafety.TextGroundedDetection', 'Groundedness Detection',
    ruleKey == 'ContentSafety.Text', 'Text Moderation',
    ruleKey == 'ContentSafety.Image', 'Image Moderation',
    ruleKey == 'ContentSafety.RaiPoliciesAPI', 'RAI Policies',
    ruleKey == 'ContentSafety.Provenance.Detect', 'Content Provenance',
    ruleKey == 'ContentSafety.AgentTaskAdherence', 'Agent Safety',
    ruleKey == 'ContentSafety.TextCustomCategories', 'Custom Categories',
    '')
| project name, kind, feature, subscriptionId
| order by name asc, feature asc
```

---

## Security & Compliance

### SEC-001 -- Managed Identities

**Function:** Summarizes managed identity adoption across Cognitive Services, ML Workspaces, and AI Search

```kql
resources
| where type in (
    'microsoft.cognitiveservices/accounts',
    'microsoft.machinelearningservices/workspaces',
    'microsoft.search/searchservices'
  )
| extend hasManagedIdentity = isnotnull(identity)
| summarize Total=count(), WithManagedIdentity=countif(hasManagedIdentity == true) by type
```

### SEC-002 -- Key Vault

**Function:** Lists Key Vaults with soft delete, purge protection, and RBAC authorization status

```kql
resources
| where type == 'microsoft.keyvault/vaults'
| extend softDelete = properties.enableSoftDelete,
         purgeProtection = properties.enablePurgeProtection,
         rbac = properties.enableRbacAuthorization
| project name, location, subscriptionId, softDelete, purgeProtection, rbac
```

### SEC-003 -- Private Networking & PE State

**Function:** Reports public network access and private endpoint connection state for AI resources

```kql
resources
| where type in (
    'microsoft.cognitiveservices/accounts',
    'microsoft.machinelearningservices/workspaces',
    'microsoft.search/searchservices',
    'microsoft.storage/storageaccounts',
    'microsoft.cache/redis'
  )
| extend publicAccess = tostring(properties.publicNetworkAccess),
         peCount = array_length(properties.privateEndpointConnections),
         peState = tostring(properties.privateEndpointConnections[0].properties.privateLinkServiceConnectionState.status)
| project name, type, publicAccess, peCount, peState, location, subscriptionId
```

### SEC-004 -- Defender for Cloud

**Function:** Shows Defender pricing tier for CloudPosture, Containers, VMs, Storage, and API plans

```kql
securityresources
| where type == 'microsoft.security/pricings'
| where name in ('CloudPosture', 'Containers', 'VirtualMachines', 'StorageAccounts', 'Api')
| project name, tier=tostring(properties.pricingTier)
```

### SEC-005 -- Defender for AI Services

**Function:** Shows Defender pricing tier for the AI plan specifically

```kql
securityresources
| where type == 'microsoft.security/pricings'
| where name == 'AI'
| project name, tier=tostring(properties.pricingTier)
```

### SEC-006 -- Model API Authentication

**Function:** Summarizes local auth disabled and public access disabled counts across AI Services

```kql
resources
| where type == 'microsoft.cognitiveservices/accounts'
| where kind in ('OpenAI', 'AIServices')
| extend disableLocalAuth = properties.disableLocalAuth,
         publicAccess = properties.publicNetworkAccess
| summarize Total=count(), LocalAuthDisabled=countif(disableLocalAuth == true), PublicDisabled=countif(publicAccess == 'Disabled')
```

### SEC-007 -- APIM as AI Gateway

**Function:** Lists API Management instances for centralized AI API access control

```kql
resources
| where type == 'microsoft.apimanagement/service'
| extend sku = tostring(sku.name),
         identity = identity.type
| project name, sku, identity, location, subscriptionId
```

---

## Monitoring & Operations

### MON-001 -- Application Insights

**Function:** Lists Application Insights instances for AI application APM

```kql
resources
| where type == 'microsoft.insights/components'
| project name, applicationId=properties.ApplicationId, ingestionMode=properties.IngestionMode, subscriptionId
```

### MON-002 -- AI Services Diagnostics

**Function:** Reports diagnostic settings coverage for Cognitive Services and ML Workspaces

```kql
resources
| where type in (
    'microsoft.cognitiveservices/accounts',
    'microsoft.machinelearningservices/workspaces'
  )
| project resourceName=name, resourceId=id, kind, subscriptionId
| join kind=leftouter (
    resources
    | where type == 'microsoft.insights/diagnosticsettings'
    | extend targetId = tostring(split(id, '/providers/microsoft.insights')[0])
    | project targetId, diagName=name, workspaceId=properties.workspaceId
) on $left.resourceId == $right.targetId
| summarize Total=count(), WithDiagnostics=countif(isnotnull(diagName)) by kind
```

### MON-003 -- Metric Alert Rules

**Function:** Lists metric alert rules targeting Cognitive Services resources

```kql
resources
| where type == 'microsoft.insights/metricalerts'
| where properties.scopes has 'microsoft.cognitiveservices'
| extend severity = toint(properties.severity),
         enabled = tobool(properties.enabled)
| project name, severity, enabled, location, subscriptionId
```

### MON-004 -- Log Analytics Workspace Coverage

**Function:** Reports how many AI resources route diagnostics to a Log Analytics workspace

```kql
resources
| where type in (
    'microsoft.cognitiveservices/accounts',
    'microsoft.machinelearningservices/workspaces',
    'microsoft.search/searchservices'
  )
| project resourceId=id, resourceName=name, type, subscriptionId
| join kind=leftouter (
    resources
    | where type == 'microsoft.insights/diagnosticsettings'
    | extend targetId = tostring(split(id, '/providers/microsoft.insights')[0])
    | project targetId, workspaceId=tostring(properties.workspaceId)
) on $left.resourceId == $right.targetId
| extend hasWorkspace = isnotnull(workspaceId)
| summarize Total=count(), RoutingToWorkspace=countif(hasWorkspace == true) by type
```

### MON-005 -- Quality Evaluators

**Type:** Manual/API

Check AI Foundry portal or API for groundedness, relevance, coherence, fluency evaluators.

```
GET https://{account}.services.ai.azure.com/api/projects/{project}/evaluations
```
