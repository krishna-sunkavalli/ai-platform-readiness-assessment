# AIRA — AI Platform Readiness Assessment
## Query Reference

---

## Data Management & Governance (DMG)

### DMG-001 — Purview Accounts
ARG
```kql
resources
| where type == 'microsoft.purview/accounts'
| project name, location, subscriptionId, properties
```

---

### DMG-002 — Purview Scan Rulesets
ARG
```kql
resources
| where type == 'microsoft.purview/accounts'
| where isnotnull(properties.scanRulesets)
| project name, location, subscriptionId, scanRulesets=properties.scanRulesets
```

---

### DMG-003 — Data Classification Rules
ARG
```kql
resources
| where type == 'microsoft.purview/accounts'
| where isnotnull(properties.cloudConnectors)
| project name, location, subscriptionId, properties
```

---

### DMG-004 — Data Lineage Enablement
ARG
```kql
resources
| where type == 'microsoft.purview/accounts'
| extend lineageEndpoint = tostring(properties.endpoints.lineage)
| where isnotnull(lineageEndpoint)
| project name, lineageEndpoint, location, subscriptionId
```

---

### DMG-005 — Unity Catalog
ARG
```kql
resources
| where type == 'microsoft.databricks/workspaces'
| extend unityCatalog = properties.parameters.enableNoPublicIp
| project name, location, subscriptionId, properties
```

---

### DMG-006 — ADF ETL Coverage
ARG
```kql
resources
| where type == 'microsoft.datafactory/factories'
| extend gitConfigured = isnotnull(properties.repoConfiguration.repositoryName),
         globalParams = array_length(bag_keys(properties.globalParameters))
| project name, location, subscriptionId, gitConfigured, globalParams
```

---

### DMG-007 — Lakehouse Presence
ARG
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

---

### DMG-008 — Retention & Lifecycle Policies on ADLS
ARG
```kql
resources
| where type == 'microsoft.storage/storageaccounts'
| where kind == 'StorageV2' and properties.isHnsEnabled == true
| extend lifecyclePolicy = isnotnull(properties.managementPolicies)
| project name, location, subscriptionId, lifecyclePolicy
```

---

## Retrieval & Context Enablement (RCE)

### RCE-001 — AI Search
ARG
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

---

### RCE-002 — Redis Cache
ARG
```kql
resources
| where type == 'microsoft.cache/redis' or type == 'microsoft.cache/redisenterprise'
| extend sku = tostring(sku.name),
         capacity = toint(sku.capacity)
| project name, sku, capacity, location, subscriptionId
```

---

### RCE-003 — Cosmos DB / PostgreSQL with pgvector
ARG
```kql
resources
| where type == 'microsoft.documentdb/databaseaccounts'
    or (type == 'microsoft.dbforpostgresql/flexibleservers')
| extend kind = case(
    type == 'microsoft.documentdb/databaseaccounts', 'Cosmos DB',
    type == 'microsoft.dbforpostgresql/flexibleservers', 'PostgreSQL Flexible',
    'Other'
  )
| extend vectorSearch = properties.capabilities has 'EnableNoSQLVectorSearch'
| project name, kind, vectorSearch, location, subscriptionId
```

---

### RCE-004 — Vector Stores
ARG
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

---

### RCE-005 — Document Intelligence
ARG
```kql
resources
| where type == 'microsoft.cognitiveservices/accounts'
| where kind == 'FormRecognizer' or kind == 'DocumentIntelligence'
| extend sku = tostring(sku.name),
         publicAccess = properties.publicNetworkAccess
| project name, kind, sku, publicAccess, location, subscriptionId
```

---

## Model Management (MDL)

### MDL-001 — Azure OpenAI / AI Services
ARG
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

---

### MDL-002 — ML Workspaces
ARG
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

---

### MDL-003 — GPU Compute
ARG
```kql
resources
| where type in ('microsoft.machinelearningservices/workspaces/computes', 'microsoft.compute/virtualmachines')
| extend vmSize = coalesce(properties.properties.vmSize, tostring(properties.hardwareProfile.vmSize))
| where vmSize contains 'NC' or vmSize contains 'ND' or vmSize contains 'NV'
| summarize count() by vmSize
```

---

### MDL-004 — AI Foundry Projects
ARG
```kql
resources
| where type =~ 'microsoft.cognitiveservices/accounts/projects'
| extend hasIdentity = isnotnull(identity.principalId),
         endpoint = tostring(properties.endpoints)
| project name, location, hasIdentity, endpoint, subscriptionId
```

---

### MDL-005 — Online Endpoints
ARG
```kql
resources
| where type == 'microsoft.machinelearningservices/workspaces/onlineendpoints'
| extend authMode = tostring(properties.authMode),
         provisioningState = tostring(properties.provisioningState)
| project name, location, authMode, provisioningState, subscriptionId
```

---

### MDL-006 — Model Deployments
ARG
```kql
resources
| where type == 'microsoft.cognitiveservices/accounts/deployments'
| extend modelName = tostring(properties.model.name),
         modelVersion = tostring(properties.model.version),
         capacityType = tostring(properties.sku.name),
         provisioningState = tostring(properties.provisioningState)
| project name, modelName, modelVersion, capacityType, provisioningState, subscriptionId
```

---

### MDL-007 — Fine-Tuned Models
ARG
```kql
resources
| where type == 'microsoft.cognitiveservices/accounts/deployments'
| where properties.model.source contains 'fine-tun'
    or properties.model.format =~ 'custom'
| extend modelName = tostring(properties.model.name),
         modelVersion = tostring(properties.model.version)
| project name, modelName, modelVersion, location, subscriptionId
```

---

### MDL-008 — AI Foundry Evaluation Runs
ARG
```kql
resources
| where type =~ 'microsoft.cognitiveservices/accounts/projects'
| extend hasEvals = isnotnull(properties.evaluations)
| project name, location, hasEvals, subscriptionId
```

---

## Responsible AI (RAI)

### RAI-001 — Content Safety
ARG
```kql
resources
| where type =~ 'microsoft.cognitiveservices/accounts'
| where kind =~ 'ContentSafety'
| project name, location, resourceGroup, subscriptionId, kind, properties
```

---

### RAI-002 — Content Filtering Enabled
ARG
```kql
resources
| where type =~ 'microsoft.cognitiveservices/accounts'
| where kind in~ ('OpenAI', 'AIServices')
| extend caps = parse_json(properties.capabilities)
| mv-expand cap = caps
| where cap.name =~ 'RaiMonitor'
| extend contentFilteringEnabled = cap.value =~ 'true'
| project name, kind, contentFilteringEnabled, location, resourceGroup, subscriptionId
```

---

### RAI-003 — Red Teaming Runs
Manual/API
```
GET https://{account}.services.ai.azure.com/api/projects/{project}/redteams/runs
Authorization: Bearer {token}

Check for completed red teaming runs and Attack Success Rate (ASR) metrics
```

---

### RAI-004 — Content Safety Feature Matrix
ARG
```kql
resources
| where type =~ 'microsoft.cognitiveservices/accounts'
| where kind in~ ('OpenAI', 'AIServices', 'ContentSafety')
| mv-expand rule = properties.callRateLimit.rules
| where tostring(rule.key) has_any ('ContentSafety', 'Jailbreak', 'PromptShield', 'ProtectedMaterial', 'Groundedness', 'CustomBlocklist', 'ImageModeration', 'TextModeration')
| extend feature = tostring(rule.key),
         renewalPeriod = tostring(rule.renewalPeriod),
         count = tostring(rule.count)
| summarize Features = make_set(feature) by name, kind, location, subscriptionId
| extend FeatureCount = array_length(Features)
| project name, kind, FeatureCount, Features, location, subscriptionId
```

---

## Security & Compliance (SEC)

### SEC-001 — Managed Identities
ARG
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

---

### SEC-002 — Key Vault
ARG
```kql
resources
| where type == 'microsoft.keyvault/vaults'
| extend softDelete = properties.enableSoftDelete,
         purgeProtection = properties.enablePurgeProtection,
         rbac = properties.enableRbacAuthorization
| project name, location, subscriptionId, softDelete, purgeProtection, rbac
```

---

### SEC-003 — Private Networking & PE State
ARG
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

---

### SEC-004 — Defender for Cloud
ARG
```kql
securityresources
| where type == 'microsoft.security/pricings'
| where name in ('CloudPosture', 'Containers', 'VirtualMachines', 'StorageAccounts', 'Api')
| project name, tier=tostring(properties.pricingTier)
```

---

### SEC-005 — Defender for AI Services
ARG
```kql
securityresources
| where type == 'microsoft.security/pricings'
| where name == 'AI'
| project name, tier=tostring(properties.pricingTier)
```

---

### SEC-006 — Model API Authentication
ARG
```kql
resources
| where type == 'microsoft.cognitiveservices/accounts'
| where kind in ('OpenAI', 'AIServices')
| extend disableLocalAuth = properties.disableLocalAuth,
         publicAccess = properties.publicNetworkAccess
| summarize Total=count(), LocalAuthDisabled=countif(disableLocalAuth == true), PublicDisabled=countif(publicAccess == 'Disabled')
```

---

### SEC-007 — APIM as AI Gateway
ARG
```kql
resources
| where type == 'microsoft.apimanagement/service'
| extend sku = tostring(sku.name),
         identity = identity.type
| project name, sku, identity, location, subscriptionId
```

---

## Monitoring & Operations (MON)

### MON-001 — Application Insights
ARG
```kql
resources
| where type == 'microsoft.insights/components'
| project name, applicationId=properties.ApplicationId, ingestionMode=properties.IngestionMode, subscriptionId
```

---

### MON-002 — AI Services Diagnostics
ARG
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

---

### MON-003 — Metric Alert Rules on Cognitive Services
ARG
```kql
resources
| where type == 'microsoft.insights/metricalerts'
| where properties.scopes has 'microsoft.cognitiveservices'
| extend severity = toint(properties.severity),
         enabled = tobool(properties.enabled)
| project name, severity, enabled, location, subscriptionId
```

---

### MON-004 — Central Log Analytics Workspace Coverage
ARG
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

---

### MON-005 — Quality Evaluators
Manual/API
```
GET https://{account}.services.ai.azure.com/api/projects/{project}/evaluations
Authorization: Bearer {token}

Check for evaluator types: groundedness, relevance, coherence, fluency
Review scores and trends over time for quality regression detection
```

---

## Summary

| Pillar | Queries | ARG | Manual/API |
|--------|---------|-----|------------|
| Data Management & Governance | 8 | 8 | 0 |
| Retrieval & Context Enablement | 5 | 5 | 0 |
| Model Management | 8 | 8 | 0 |
| Responsible AI | 4 | 3 | 1 |
| Security & Compliance | 7 | 7 | 0 |
| Monitoring & Operations | 5 | 4 | 1 |
| **Total** | **37** | **35** | **2** |
