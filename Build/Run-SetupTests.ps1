param(
    [Parameter(Mandatory = $true)]
    [string] $studioLicenseCode,

    [Parameter(Mandatory = $true)]
    [string] $setupScriptsFolder,

    [Parameter(Mandatory = $true)]
    [string] $outputFolder,

    [Parameter(Mandatory = $true)]
    [string] $pesterModulePath,

    [string[]] $includeTags,
    [string[]] $excludeTags
)

Import-Module $pesterModulePath

Get-ChildItem $setupScriptsFolder -Recurse -File -Include "*.Tests.ps1" | `
ForEach-Object {
    
    $testDescriptor = @{
        Path = $_.FullName;
        Parameters = @{
            licenseCode = $studioLicenseCode
        };
    }

    $outputFile = Join-Path $outputFolder "Test-$([system.IO.Path]::GetFileNameWithoutExtension($_.Name)).xml"

    Set-Location $_.Directory.FullName

    $invokePesterArgs = @{
        Script = $testDescriptor;
        OutputFile = $outputFile;
        OutputFormat = "NUnitXML";
    }

    if ($includeTags) {
        $invokePesterArgs.Tag = $includeTags
    }

    if ($excludeTags) {
        $invokePesterArgs.ExcludeTag = $excludeTags
    }

    $pesterResult = Invoke-Pester @invokePesterArgs -PassThru -Verbose

    if ($pesterResult.FailedCount -gt 0) {
        Write-Error "$($pesterResult.FailedCount) tests failed"
        Exit 1
    }
}
