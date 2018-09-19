param(
    [Parameter(Mandatory = $true)]
    [string] $installationDirectory,

    [string] $moduleVersion = "4.3.1"
)

$moduleName = "Pester"
$modulePath = "$home\Documents\WindowsPowerShell\Modules\$moduleName\$moduleVersion"

Install-Module -Name $moduleName -RequiredVersion $moduleVersion -Scope CurrentUser -AllowClobber -Force -SkipPublisherCheck -Verbose

$moduleDestinationPath = Join-Path $installationDirectory $moduleName

if (Test-Path $moduleDestinationPath) {
    Write-Host "Removing existing module directory '$moduleDestinationPath'"
    Remove-Item $moduleDestinationPath -Recurse -Force
}

New-Item -Path $moduleDestinationPath -ItemType Directory

Copy-Item $modulePath -Destination $moduleDestinationPath -Recurse
