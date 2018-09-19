
function Assert-NoEventLogErrorsExist {

    $eventProviders = @("MsiInstaller", "ESENT")
    $applicationErrorLogs = @()

    foreach ($eventProvider in $eventProviders) {

        $getWinEventFilter = @{
            logname = "application";
            starttime = [datetime]::Today;
            level = "2";
            providername = $eventProvider;
        }

        $applicationErrorLogs += Get-WinEvent $getWinEventFilter -ErrorAction SilentlyContinue
    }

    $applicationErrorLogs.Count | Should -Be 0
}

function Assert-StudioLicenseFileExists {
    (Get-ChildItem "$($ENV:ProgramData)\UiPath\License\*.lic").Length | Should -BeGreaterThan 0
}

function Assert-UiPathStudioInstalled {
    Assert-ProgramInstalled "UiPath Studio"
}

function Assert-UiPathOrchestratorInstalled {
    Assert-ProgramInstalled "UiPath Orchestrator"
}

function Assert-ActivityPackagesInstalled {

    param(
        [string] $customStudioPath
    )

    Assert-UiPathActivityPackageInstallation -packageName "UiPath.Core.Activities*" -customStudioPath $customStudioPath
    Assert-UiPathActivityPackageInstallation -packageName "UiPath.Mail.Activities*" -customStudioPath $customStudioPath
    Assert-UiPathActivityPackageInstallation -packageName "UiPath.Excel.Activities*" -customStudioPath $customStudioPath
}

function Assert-UiPathActivityPackageInstallation {

    param(
        [Parameter(Mandatory = $true)]
        [string] $packageName,

        [string] $customStudioPath,

        [ValidateSet("Installed", "NotInstalled")]
        [string] $state = "Installed"
    )

    $basePath = ""

    if ($customStudioPath) {
        $basePath = $customStudioPath
    } else {
        switch ((Get-WmiObject Win32_OperatingSystem).OSArchitecture) {
            "64-bit"{
                $basePath = "${ENV:ProgramFiles(x86)}\UiPath\Studio"
            }
            "32-bit"{
                $basePath = "${ENV:ProgramFiles}\UiPath\Studio"		
            }
        }
    }

    switch ($state) {
        "Installed" {
            Assert-FileExists "$basePath\Packages\$packageName.nupkg"
        }
        "NotInstalled" {
            Assert-FileDoesntExist "$basePath\Packages\$packageName.nupkg"
        }
    }
}

function Assert-UiPathDesktopShortcutsExistInStartMenu {

    param(
        [switch] $isClickOnce
    )

    Assert-StartMenuShortcutExists -name "UiPath Studio.lnk" -isClickOnce:$isClickOnce
    Assert-StartMenuShortcutExists -name "UiPath Robot.lnk" -isClickOnce:$isClickOnce
}

function Assert-StartMenuShortcutExists {

    param(
        [Parameter(Mandatory = $true)]
        [string] $name,

        [switch] $isClickOnce
    )

    Assert-StartMenuShortcutState -name $name -isClickOnce:$isClickOnce
}

function Assert-StartMenuShortcutDoesntExist {
    
    param(
        [Parameter(Mandatory = $true)]
        [string] $name,

        [switch] $isClickOnce
    )

    Assert-StartMenuShortcutState -name $name  -isClickOnce:$isClickOnce -notExists
}

function Assert-StartMenuShortcutState {
    
    param(
        [Parameter(Mandatory = $true)]
        [string] $name,

        [switch] $isClickOnce,

        [switch] $notExists
    )

    $startMenuItems = Get-StartMenuItems -match $name -isClickOnce:$isClickOnce

    $found = $false

    foreach ($item in $startMenuItems) {

        if ($item.ShortcutName -eq $name) {
            $found = $true
            break
        }
    }

    if ($notExists) {
        $found | Should -BeFalse
    } else {
        $found | Should -BeTrue
    }
}

function Get-StartMenuItems {

    param(
        [AllowEmptyString()]
        [string] $match,

        [switch] $isClickOnce
    )

    $pathToSearch = if ($isClickOnce) {
        "$($ENV:APPDATA)\Microsoft\Windows\Start Menu\Programs"
    } else {
        "$($Env:ProgramData)\Microsoft\Windows\Start Menu\Programs"
    }

    $shortcuts = Get-ChildItem $pathToSearch -Recurse -Include *.lnk | Where-Object {
        !$match -or $_.Name -match $match
    }

    [System.Collections.ArrayList] $startMenuItems = New-Object System.Collections.ArrayList

    foreach ($shortcut in $shortcuts) {
        
        $comShell = New-Object -ComObject WScript.Shell

        try {

            $comShellShortcut = $comShell.CreateShortcut($shortcut)

            $item = New-Object psobject -Property @{
                LinkTarget = $comShellShortcut.targetpath;
                ShortcutName = $shortcut.Name;
            }
            
            $startMenuItems.Add($item) | Out-Null  
            
        } catch {
            throw $_
        } finally {
            [Runtime.InteropServices.Marshal]::ReleaseComObject($comShell) | Out-Null
        }
    }

    return $startMenuItems
}

function Assert-MSIExecOk {

    param(
        [Parameter(Mandatory = $true)]
        [System.Object] $msiExecResults
    )

    if ($msiExecResults.LogPath -and (Test-Path $msiExecResults.LogPath)) {

        $logText = [System.IO.File]::ReadAllText($msiExecResults.LogPath)
        $possibleErrors = ([regex]"Error \d+.+").Matches($logText) | Select-Object -ExpandProperty "Value"

        if ($possibleErrors.Length -gt 0) {
            Write-Warning "Found possible errors in msiexec log file:"

            $possibleErrors | ForEach-Object {
                Write-Warning "[Possible error] $($_)"
            }
        }
    }

    Assert-ProcessExitCode -process $msiExecResults.MSIExecProcess -exitCode 0
}

function Assert-ProcessExitCode {

    param(
        [Parameter(Mandatory = $true)]
        [System.Diagnostics.Process] $process,

        [int] $exitCode
    )

    $process.ExitCode | Should -BeExactly $exitCode
}

function Assert-RobotTrayProcessState {

    param(
        [ValidateSet("Running", "NotRunning")]
        [string] $state = "Running"
    )

    Assert-ProcessState -processName "UiPath.Agent.exe" -state $state
}

function Assert-RobotServiceState {
    
    param(
        [ValidateSet("Running", "NotRunning")]
        [string] $state = "Running"
    )

    Assert-ServiceState -serviceName "UiRobotSvc" -state $state
}

function Assert-ProcessState {

    param(
        [Parameter(Mandatory = $true)]
        [string] $processName,

        [ValidateSet("Running", "NotRunning")]
        [string] $state = "Running"
    )

    $processesCount = (Get-Process $processName -ErrorAction SilentlyContinue).Length
    
    switch ($state) {
        "Running" {
            $processesCount | Should -BeGreaterOrEqual 1
        }
        "NotRunning" {
            $processesCount | Should -BeExactly 0
        }
    }
}

function Assert-ServiceState {

    param(
        [Parameter(Mandatory = $true)]
        [string] $serviceName,

        [ValidateSet("Running", "NotRunning")]
        [string] $state = "Running"
    )

    (Get-Service -Name $serviceName).status | Should -BeExactly $state
}

function Assert-FileExists {

    param(
        [Parameter(Mandatory = $true)]
        [string] $path
    )

    Test-Path $path | Should -BeTrue
}

function Assert-FileDoesntExist {
    
    param(
        [Parameter(Mandatory = $true)]
        [string] $path
    )

    Test-Path $path | Should -BeFalse
}

function Assert-ChildItemsExist {
    
    param(
        [Parameter(Mandatory = $true)]
        [string] $path,

        [string] $include
    )

    $getChildItemArgs = @{
        Path = $path;
    }

    if ($include) {
        $getChildItemArgs.Include = $include
    }

    $childItems = Get-ChildItem @getChildItemArgs
    
    $childItems.Length | Should -BeGreaterThan 0
}

function Assert-ProgramInstalled {

    param(
        [Parameter(Mandatory = $true)]
        [string] $displayName,

        [switch] $isClickOnce
    )

    $uninstallPropsExist = [boolean](Get-UninstallItemProperties -displayName $displayName -isClickOnce:$isClickOnce)

    $uninstallPropsExist | Should -BeTrue
}

function Assert-ProgramVersionMatches {

    param(
        [Parameter(Mandatory = $true)]
        [string] $displayName,

        [Parameter(Mandatory = $true)]
        [string] $displayVersion,

        [switch] $isClickOnce
    )

    Get-UninstallItemProperties -displayName $displayName -isClickOnce:$isClickOnce | `
        Select-Object -ExpandProperty "DisplayVersion" | `
        Should -Match $displayVersion
}


function Get-UninstallItemProperties {

    param(
        [Parameter(Mandatory = $true)]
        [string] $displayName,

        [switch] $isClickOnce
    )

    if ($isClickOnce) {
        return (Get-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*" | Where-Object { $_.DisplayName -like $displayName })
        break
    }

    switch ((Get-WmiObject Win32_OperatingSystem).OSArchitecture) {
        "64-bit"{
            return (Get-ItemProperty "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" | Where-Object { $_.DisplayName -like $displayName })
            break
        }
        "32-bit" {
            return (Get-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*" | Where-Object { $_.DisplayName -like $displayName })
            break
        }
    }
}

function Uninstall-Program {

    param(
        [Parameter(Mandatory = $true)]
        [string] $displayName,

        [switch] $isClickOnce
    )

    if ($isClickOnce) {

        $uninstallString = Get-ChildItem "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall" | `
            ForEach-Object { Get-ItemProperty $_.PsPath } | `
            Where-Object { $_.DisplayName -eq $displayName } | `
            Select-Object -ExpandProperty "UninstallString"

        Write-Verbose "Uninstalling '$displayName'"
        cmd /c $uninstallString

        break
    }

    Write-Verbose "Querying WMI for '$displayName'"
    $app = Get-WmiObject -Class "Win32_Product" -Filter "Name = '$displayName'"

    Write-Verbose "Uninstalling '$displayName'"
    $app.Uninstall()
}
