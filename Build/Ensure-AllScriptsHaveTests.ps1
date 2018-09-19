<#
.DESCRIPTION
Ensures that all .ps1 files in a directory have test files that cover them

.PARAMETER directory
The directory in which to recursively search

.PARAMETER testignore
The path to a file containing paths that should be ignored when searching for tests.
The paths are relative to the directory parameter
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string] $directory,

    [AllowEmptyString()]
    [string] $testignore
)

$ErrorActionPreference = "Stop"

function Main() {
    
    if (!(Test-Path $directory)) {
        Write-Error "The directory '$directory' doesn't exist"
        Exit 1
    }

    $ignoredPaths = @()

    if ($testignore) {

        if (!(Test-Path $testignore)) {
            Write-Error "No test ignore file found at path '$testignore'"
            Exit 1
        }

        Write-Verbose "Using test ignore file '$testignore'"

        $ignoredPaths = Get-Content $testignore | `
            Where-Object { !([string]::IsNullOrWhiteSpace($_)) }
    }

    $untestedScripts = @()

    Get-ChildItem $directory -Include "*.ps1" -Recurse -File | `
        ForEach-Object {

            $shouldCheckForTests = !$_.Name.EndsWith("Tests.ps1") -and !(Should-IgnoreScript $_.FullName $ignoredPaths)

            if ($shouldCheckForTests) {

                $scriptTestPath = Join-Path ($_.Directory.FullName) "$([System.IO.Path]::GetFileNameWithoutExtension($_.Name)).Tests.ps1"

                if (!(Test-Path $scriptTestPath)) {
                    $untestedScripts += $_.FullName
                } else {
                    Write-Verbose "$($_.FullName) is tested by $scriptTestPath"
                }

            } else {
                Write-Verbose "Ignoring $($_.FullName)"
            }
        }

    if ($untestedScripts.Length -ne 0) {

        $errorMessage = "$([Environment]::NewLine)There are untested PowerShell scripts: $([Environment]::NewLine)"
        $errorMessage += $untestedScripts | ForEach-Object { "" + $_ + [Environment]::NewLine }

        Write-Error $errorMessage
        Exit 1

    } else {
        Write-Host "$([Environment]::NewLine)All scripts have tests" -ForegroundColor Green
    }
}

function Should-IgnoreScript {

    param(
        [Parameter(Mandatory = $true)]
        [string] $scriptPath,

        [Parameter(Mandatory = $true)]
        [string[]] $ignoredPaths
    )

    $normalizedScriptPath = $scriptPath -replace "\\","/"
    $isIgnored = $false

    $ignoredPaths | ForEach-Object {
        $absoluteIgnoredPath = (Join-Path $directory $_) -replace "\\","/"

        if ($normalizedScriptPath -eq $absoluteIgnoredPath -or $normalizedScriptPath.StartsWith($absoluteIgnoredPath)) {
            $isIgnored = $true
        }
    }

    return $isIgnored
}

Main
