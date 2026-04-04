<#
.SYNOPSIS
    Regenerates the ARM template (azuredeploy.json) from the workbook source file.
.DESCRIPTION
    Reads the workbook JSON, validates it, and embeds it into the ARM template
    as the serializedData property.
.EXAMPLE
    .\scripts\build-arm-template.ps1
#>
[CmdletBinding()]
param(
    [string]$WorkbookPath = (Join-Path $PSScriptRoot '..\workbook\ai-readiness-assessment.workbook'),
    [string]$OutputPath   = (Join-Path $PSScriptRoot '..\workbook\azuredeploy.json')
)

$ErrorActionPreference = 'Stop'

# Validate workbook JSON
$wbRaw = Get-Content $WorkbookPath -Raw
try {
    $null = $wbRaw | ConvertFrom-Json
    Write-Host "✓ Workbook JSON is valid" -ForegroundColor Green
} catch {
    Write-Error "Workbook JSON is invalid: $($_.Exception.Message)"
    exit 1
}

# Escape for embedding into JSON string
$escaped = $wbRaw.Replace('\', '\\').Replace('"', '\"').Replace("`r`n", '\n').Replace("`n", '\n').Replace("`t", '\t')

# Build ARM template
$arm = @"
{
  "`$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "metadata": {
    "description": "Deploys the AI Platform Readiness Assessment workbook to Azure Monitor.",
    "author": "Microsoft",
    "version": "1.0.0"
  },
  "parameters": {
    "workbookDisplayName": {
      "type": "string",
      "defaultValue": "AI Platform Readiness Assessment",
      "metadata": {
        "description": "Display name for the Azure Workbook"
      }
    },
    "workbookSourceId": {
      "type": "string",
      "defaultValue": "Azure Monitor",
      "metadata": {
        "description": "Source ID for the workbook (use 'Azure Monitor' for standalone)"
      }
    },
    "location": {
      "type": "string",
      "defaultValue": "[resourceGroup().location]",
      "metadata": {
        "description": "Location for the workbook resource"
      }
    },
    "tags": {
      "type": "object",
      "defaultValue": {},
      "metadata": {
        "description": "Resource tags to apply to the workbook"
      }
    }
  },
  "variables": {
    "workbookId": "[guid(resourceGroup().id, parameters('workbookDisplayName'))]"
  },
  "resources": [
    {
      "type": "Microsoft.Insights/workbooks",
      "apiVersion": "2022-04-01",
      "name": "[variables('workbookId')]",
      "location": "[parameters('location')]",
      "tags": "[parameters('tags')]",
      "kind": "shared",
      "properties": {
        "displayName": "[parameters('workbookDisplayName')]",
        "serializedData": "$escaped",
        "category": "workbook",
        "sourceId": "[parameters('workbookSourceId')]"
      }
    }
  ],
  "outputs": {
    "workbookId": {
      "type": "string",
      "value": "[variables('workbookId')]"
    }
  }
}
"@

$arm | Set-Content $OutputPath -Encoding UTF8

# Validate the output
try {
    $parsed = $arm | ConvertFrom-Json
    $null = $parsed.resources[0].properties.serializedData | ConvertFrom-Json
    Write-Host "✓ ARM template written to $OutputPath" -ForegroundColor Green
    Write-Host "✓ Embedded workbook round-trips successfully" -ForegroundColor Green
} catch {
    Write-Error "Generated ARM template is invalid: $($_.Exception.Message)"
    exit 1
}
