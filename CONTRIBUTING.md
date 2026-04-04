# Contributing to AI Platform Readiness Assessment

This project welcomes contributions and suggestions. Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## How to Contribute

### Reporting Issues

- Search [existing issues](https://github.com/microsoft/ai-platform-readiness-assessment/issues) first
- Use the appropriate issue template (bug report or feature request)
- Include as much detail as possible

### Submitting Changes

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/my-change`)
3. Make your changes
4. Validate the workbook JSON is valid:
   ```bash
   python -c "import json; json.load(open('workbook/ai-readiness-assessment.workbook'))"
   ```
5. If you modified the workbook, regenerate `azuredeploy.json`:
   ```powershell
   .\scripts\build-arm-template.ps1
   ```
6. Commit your changes (`git commit -m 'Add new check for ...'`)
7. Push to your fork (`git push origin feature/my-change`)
8. Open a Pull Request

### Adding New Queries

To add a new ARG query to the workbook:

1. Add the query to the appropriate pillar section in `workbook/ai-readiness-assessment.workbook`
2. Follow the existing naming convention (`{PILLAR}-{###}`)
3. Test the query against Azure Resource Graph:
   ```powershell
   Search-AzGraph -Query "your query here" -First 5
   ```
4. Update `docs/QUERIES.md` with the new query reference
5. Run the validation workflow locally before submitting

### Query Guidelines

- All ARG queries must be tested against a live Azure environment
- Use lowercase resource type names (e.g., `microsoft.cognitiveservices/accounts`)
- Avoid overriding built-in ARG columns (`kind`, `id`, `name`, `type`, etc.) with `extend`
- Include `subscriptionId` in projections for multi-subscription support
- Add `noDataMessage` to workbook grid items

## Repository Setup (Maintainers)

After creating the repo on GitHub, configure the following **branch protection rules** on `main`:

1. **Settings → Branches → Add rule** for `main`
2. Enable:
   - ✅ Require a pull request before merging (1+ approving review)
   - ✅ Dismiss stale pull request approvals when new commits are pushed
   - ✅ Require status checks to pass before merging
     - Add: `Validate JSON & Structure`, `Lint PowerShell Scripts`
   - ✅ Require conversation resolution before merging
   - ✅ Do not allow bypassing the above settings
3. Optionally enable **Require signed commits** for stricter provenance

> **Note:** CI validates workbook structure only. Live ARG query testing (`validate-queries.ps1`) requires Azure credentials. To automate this on PRs, add an `AZURE_CREDENTIALS` secret to the repo and create a separate workflow with `pull_request` trigger.

## Development Setup

### Prerequisites

- PowerShell 7.0+
- Azure PowerShell module (`Az.Accounts`, `Az.ResourceGraph`)
- Azure subscription with **Reader** role

### Local Testing

```powershell
# Connect to Azure
Connect-AzAccount

# Validate all queries
.\scripts\validate-queries.ps1
```
