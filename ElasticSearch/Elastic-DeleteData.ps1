###
###
###
###
param(
[Parameter(Mandatory=$true,HelpMessage="Delete data older than X days")][ValidateScript({$_ -ge 0})][int]$daysToKeep,
[Parameter(Mandatory=$true,HelpMessage="Enter the ElasticSearch URL")][ValidateNotNullOrEmpty()][ValidatePattern( "^(http|https)://" )][string]$elasticURL,
[Parameter(HelpMessage="Optional, 'default' is used if nothing else is entered here")][string]$tenantName="default",
[Parameter(HelpMessage="Optional, 'elastic' is used if nothing else is entered here")][string]$elasticUser="elastic",
[Parameter(HelpMessage="Optional, 'changeme' is used if nothing else is entered here")][string]$elasticPassword="changeme"
)

function quit() {
    Break Script
}

function writeLog($text)
{
    Write-EventLog -LogName Application -Source “DeleteOldElasticSearchDataScript” -EventId 1 -Message $text
    Write-Host $text
}

if ([System.Diagnostics.EventLog]::SourceExists("DeleteOldElasticSearchDataScript") -eq $False)
{
    New-EventLog –LogName Application –Source “DeleteOldElasticSearchDataScript”
}



$elasticPassword=$elasticPassword | ConvertTo-SecureString -AsPlainText -Force
$credential = New-Object -TypeName PSCredential($elasticUser,$elasticPassword)

try
{
    $webclient = New-Object system.net.webclient
    $indexes=New-Object System.Collections.ArrayList
    
    $indexes = (Invoke-WebRequest -Uri $($($elasticURL) + '/_alias') -ContentType 'application/json' -Method Get).content
    
    $indexeslist=New-Object System.Collections.ArrayList
    $indexeslist =[string[]]($indexes.split('"',[System.StringSplitOptions]::RemoveEmptyEntries) | Select-String -AllMatches $tenantName) | Sort-Object

    if($indexeslist.Length -eq 0)
    {
        writeLog("Tenant "+$tenantName+" not found. Quiting script.")
        quit
    }

    $days = $daysToKeep
	[datetime]$currentDate=Get-Date
    [datetime]$deltaDate=$currentDate.AddDays(-$days)

    $deltaDate
    $deltaDate=$deltaDate.AddMonths(-1)
    $deltaDate

    $monthToDeleteFrom=[int]$deltaDate.Month
    $yearToDeleteFrom=[int]$deltaDate.Year

    if($monthToDeleteFrom -eq 0)
    {
        $monthToDeleteFrom=12
    }

    if($monthToDeleteFrom -lt 10)
    {
        $indexToDeleteFrom=$tenantName+"-"+$yearToDeleteFrom+"."+"0"+$monthToDeleteFrom
    }
    else
    {
        $indexToDeleteFrom=$tenantName+"-"+$yearToDeleteFrom+"."+$monthToDeleteFrom
    }

    write-host "indexes:" 
    $indexeslist | ft
    write-host "indexToDeleteFrom:"
    $indexToDeleteFrom | ft
    Write-Host "------------------------------------------------"

    $position=$indexeslist.IndexOf($indexToDeleteFrom)
    $position

    $indexeslist.Item(0)

    while($indexeslist.IndexOf($indexToDeleteFrom) -eq -1)
    {

    #$var=$indexeslist.IndexOf($indexToDeleteFrom).CompareTo($indexeslist.Item(0))
    if($indexToDeleteFrom -le $indexeslist.Item(0))
    {
    write-host "there are no indices older than" $indexeslist.Item(0)
    quit}
    

    $m=$deltaDate.AddMonths(-1)
    $monthToDeleteFrom=[int]$m.Month

    if($monthToDeleteFrom -lt 10)
    {
        $indexToDeleteFrom=$tenantName+"-"+$yearToDeleteFrom+"."+"0"+$monthToDeleteFrom
    }
    else
    {
        $indexToDeleteFrom=$tenantName+"-"+$yearToDeleteFrom+"."+$monthToDeleteFrom
    }

    $indexToDeleteFrom | ft
    $position=$indexeslist.IndexOf($indexToDeleteFrom)
    $position



    }
    
    $results=@{}
 
    for($i=0;$i -le $position;$i++)
    {   
        write-host "position " $i
        write-host "index " $indexeslist.GetValue($i)    
        $indexeslist.GetValue($i) | ForEach-Object {
            $status=(Invoke-WebRequest -uri "$($elasticURL)/$($_)" -Credential $credential -Method Delete -ContentType 'application/json').statuscode          
            write-host "status: " $status 
            write-host "index: " $indexeslist.GetValue($i)
            $results.Add($indexeslist.GetValue($i),$status)
        }
    }
    foreach($key in $results.keys)
    {
        if($results[$key] -eq 200)
        {
            $message = 'Operation on index {0} returned status OK.' -f $key
            writeLog($message)
        }
        else
        {
            $message = 'Operation on index {0} returned status {1}.' -f $key,$results[$key]
            writeLog($message)
        }
        
    }
}
catch
{
    writeLog("Ran into an issue: $($PSItem.ToString())")

}
finally
{
    writeLog("Script ended.")
    quit
}