<#
.SYNOPSIS
    Validates all ARG queries from the workbook against a live Azure environment.
.DESCRIPTION
    Extracts embedded KQL queries from the workbook JSON and runs each one via
    Search-AzGraph to confirm there are no syntax or runtime errors.
.EXAMPLE
    Connect-AzAccount
    .\scripts\validate-queries.ps1
#>
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

# Check Azure connection
$ctx = Get-AzContext
if (-not $ctx) {
    Write-Error "Not connected to Azure. Run Connect-AzAccount first."
    exit 1
}
Write-Host "Connected as $($ctx.Account) to tenant $($ctx.Tenant.Id)" -ForegroundColor Cyan

# Load workbook
$wbPath = Join-Path $PSScriptRoot '..\workbook\ai-readiness-assessment.workbook'
$wb = Get-Content $wbPath -Raw | ConvertFrom-Json

# Recursively extract all queries
function Get-Queries($items) {
    $queries = @()
    foreach ($item in $items) {
        if ($item.type -eq 3 -and $item.content.query) {
            $queries += [PSCustomObject]@{
                Name  = $item.name
                Query = $item.content.query
            }
        }
        if ($item.content.items) {
            $queries += Get-Queries $item.content.items
        }
        if ($item.content.parameters) {
            foreach ($p in $item.content.parameters) {
                if ($p.query) {
                    $queries += [PSCustomObject]@{
                        Name  = $p.name
                        Query = $p.query
                    }
                }
            }
        }
    }
    return $queries
}

$queries = Get-Queries $wb.items
Write-Host "Found $($queries.Count) queries to validate`n" -ForegroundColor Cyan

$pass = 0
$fail = 0
$failures = @()

foreach ($q in $queries) {
    try {
        $null = Search-AzGraph -Query $q.Query -First 1 -ErrorAction Stop
        Write-Host "  PASS  $($q.Name)" -ForegroundColor Green
        $pass++
    } catch {
        $msg = if ($_.Exception.Response.Content) {
            ($_.Exception.Response.Content | ConvertFrom-Json).error.details[-1].message
        } else {
            $_.Exception.Message
        }
        Write-Host "  FAIL  $($q.Name): $msg" -ForegroundColor Red
        $fail++
        $failures += "$($q.Name): $msg"
    }
}

Write-Host "`n--- Results ---"
Write-Host "Passed: $pass" -ForegroundColor Green
Write-Host "Failed: $fail" -ForegroundColor $(if ($fail -gt 0) { 'Red' } else { 'Green' })

if ($fail -gt 0) {
    Write-Host "`nFailures:" -ForegroundColor Red
    $failures | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
    exit 1
}
