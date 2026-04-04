# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [1.1.0] - 2026-04-03

### Added

- **RAI-002 Content Filtering Enabled** — Replaced manual Safety Evaluators check with ARG query that detects `RaiMonitor` capability on Azure OpenAI / AI Services accounts
- **RAI-004 Content Safety Feature Matrix** — New ARG query showing 10 content safety features per AI account: Jailbreak Detection, Prompt Shield, Protected Material, Groundedness Detection, Text/Image Moderation, RAI Policies, Content Provenance, Agent Safety, Custom Categories
- **AI Resource Landscape** — New informational summary section with bubble map and breakdown table showing AI resources by region and service category (does not affect scoring)
- **Release workflow** (`.github/workflows/release.yml`) — Tag-triggered GitHub Actions workflow that validates, packages, and creates a GitHub Release with versioned artifacts and Deploy-to-Azure button
- **Dependabot** (`.github/dependabot.yml`) — Weekly GitHub Actions version monitoring
- **CODEOWNERS** — Team-based auto-assignment for PR reviews
- **.editorconfig** — Consistent formatting across contributors
- **Branch protection guide** in CONTRIBUTING.md — Post-repo-creation setup instructions

### Changed

- Total queries: 36 → 37 (35 ARG + 2 manual)
- Manual checks reduced from 3 to 2 (RAI-002 is now automated)
- CI workflow (`validate.yml`) — Removed path filters, added ARM/workbook sync check, added PSScriptAnalyzer linting job
- ARM template (`azuredeploy.json`) — Added `metadata` block (description, author, version) and `tags` parameter
- Build script (`build-arm-template.ps1`) — Generates metadata and tags in ARM template
- `.gitignore` — Added `.env`, `.env.local`, `*.code-workspace` patterns
- README — Added maintainer callout for branch protection, updated repo structure, screenshot reference moved to TODO comment

### Fixed

- **RCE-003** — Renamed `extend kind = case(...)` to `extend dbKind = case(...)` to avoid overriding ARG built-in `kind` column

## [1.0.0] - 2026-04-02

### Added

- Initial release with 36 assessment queries across 6 pillars
- **Data Management & Governance (8 queries)**: Purview accounts, scan rulesets, data classification, lineage, Databricks Unity Catalog, ADF ETL, Lakehouse (ADLS/Databricks/Fabric), retention policies
- **Retrieval & Context Enablement (5 queries)**: AI Search (with vector capability), Redis Cache, Cosmos DB / PostgreSQL, vector stores inventory, Document Intelligence
- **Model Management (8 queries)**: Azure OpenAI / AI Services, ML workspaces, GPU compute, AI Foundry projects, online endpoints, model deployments, fine-tuned models, evaluation runs
- **Responsible AI (3 queries)**: Content Safety (ARG), safety evaluators (Manual/API), red teaming runs (Manual/API)
- **Security & Compliance (7 queries)**: Managed identities, Key Vault, private networking, Defender for Cloud, Defender for AI, model API authentication, APIM as AI gateway
- **Monitoring & Operations (5 queries)**: Application Insights, AI services diagnostics, metric alerts, Log Analytics workspace coverage, quality evaluators (Manual/API)
- Interactive HTML summary with pillar score bars and overall AI readiness ring
- ARM template (`azuredeploy.json`) for one-click deployment
- Deploy to Azure button
- GitHub Actions CI for JSON validation
