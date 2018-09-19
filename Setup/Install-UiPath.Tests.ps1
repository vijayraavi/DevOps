param(
    [Parameter(Mandatory = $true)]
    [string] $licenseCode,

    [string] $testsModulePath = "$PSScriptRoot\Setup.Tests.psm1"
)

Import-Module $testsModulePath

Describe -Name "Installing latest beta UiPath Studio enterprise" `
    -Tag @("latest", "beta", "studio", "enterprise") {

    .\Install-UiPath.ps1 -Verbose `
        -beta `
        -licenseCode $licenseCode

    It "Should install UiPath Studio" {
        Assert-ProgramInstalled -displayName "UiPath Studio"
    }

    It "Should install a beta version of UiPath Studio" {
        Assert-ProgramVersionMatches -displayName "UiPath Studio" -displayVersion "^\d+\.\d+\.\d+\-beta"
    }

    Uninstall-Program -displayName "UiPath Studio" -Verbose
}

Describe -Name "Installing latest beta UiPath Studio community" `
    -Tag @("latest", "beta", "studio", "community") {

    .\Install-UiPath.ps1 -Verbose `
        -beta `
        -community `
        -licenseCode $licenseCode

    It "Should install UiPath Studio" {
        Assert-ProgramInstalled -displayName "UiPath Studio" -isClickOnce
    }

    It "Should install a beta version of UiPath Studio" {
        Assert-ProgramVersionMatches -displayName "UiPath Studio" -displayVersion "^\d+\.\d+\.\d+\-beta" -isClickOnce
    }

    Uninstall-Program -displayName "UiPath Studio" -isClickOnce -Verbose
}

Describe -Name "Installing 18.2.* stable UiPath Studio enterprise" `
    -Tag @("18.2", "stable", "studio", "enterprise") {

    .\Install-UiPath.ps1 -Verbose `
        -version "18.2.*" `
        -licenseCode $licenseCode

    It "Should install UiPath" {
        Assert-ProgramInstalled -displayName "UiPath"
    }

    It "Should install an 18.2.* version of UiPath" {
        Assert-ProgramVersionMatches -displayName "UiPath" -displayVersion "^18\.2\.\d+"
    }

    Uninstall-Program -displayName "UiPath" -Verbose
}

Describe -Name "Installing 18.2.* stable UiPath Studio community" `
    -Tag @("18.2", "stable", "studio", "community") {

    .\Install-UiPath.ps1 -Verbose `
        -version "18.2.*" `
        -community `
        -licenseCode $licenseCode

    It "Should install UiPath" {
        Assert-ProgramInstalled -displayName "UiPath Studio" -isClickOnce
    }

    It "Should install an 18.2.* version of UiPath Studio" {
        Assert-ProgramVersionMatches -displayName "UiPath Studio" -displayVersion "^18\.2\.\d+" -isClickOnce
    }

    Uninstall-Program -displayName "UiPath Studio" -isClickOnce -Verbose
}
