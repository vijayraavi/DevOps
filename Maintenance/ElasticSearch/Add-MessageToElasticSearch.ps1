## insert a particular messageBody in elastic search. If index does not exist it is created

<#

.SYNOPSIS
This script adds a particular message to elastic search.

.DESCRIPTION
This script adds a particular message to elastic search. If the index does not exist it is automatically created.
The script is meant to be used after installation of Elasticsearch and Kibana, for 2 purposes:
- to prove that the Elasticsearch URL is good to be used (machine reachable, port open, service started)
- to be able to create the index pattern in Kibana

.EXAMPLE
.\AddMessageToElasticSearch.ps1 -uri http://localhost:9200 -indexName testIndex -messageType logEvent
.\AddMessageToElasticSearch.ps1 -uri http://localhost:9200 -indexname default-2017.01
.NOTES
Put some notes here.

#>

#### Script parameters ####
 param (
    [string]$uri,   		                        # $uri  - #Elastic search URL
    [string]$indexName,		  		        # $indexName - the name of the index
    [string]$messageType = "logEvent",			# $messageType = "logEvent" # the _type property from Elasticsearch
	[string]$message = "hello Elasticsearch!!!"   	# $message to add
 )

if ([string]::IsNullOrEmpty($indexname))
{
    $indexname = "default-" + [DateTime]::UtcNow.Year.ToString() + "." + [DateTime]::UtcNow.Month.ToString('00')
}

if ([string]::IsNullOrEmpty($uri))
{
    $uri = "http://" + $env:COMPUTERNAME + ":9200"
}


$messageBody = @{ 
 message=$message
 "@timestamp" = [DateTime]::UtcNow.ToString('o')
}


### End SCRIPT Parameters

$WebRequestPath = [string]::Format("{0}/{1}/{2}",$uri,$indexName.ToLower(),$messageType)

Write-Output "Executing post call to " + $WebRequestPath.ToString() + " with body " (ConvertTo-Json $messageBody)
Invoke-WebRequest -Uri $WebRequestPath -Method POST -Body (ConvertTo-Json $messageBody)
