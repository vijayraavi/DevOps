# UiPath Orchestrator

This template creates an App Service, SQL Server and SQL Database in a resource group, configured for deploying **UiPath Orchestrator**.

To help speed up things, we have built a set of predefined deployment sizes:

## Small deployment (<250 robots)

[![Deploy to Azure](https://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FUiPath%2FDevOps%2Ffeature%2Forchestrator_arm_templates%2FARM%2Fuipath-orchestrator%2Fazuredeploy.small.json)

Supports up to 250 connected robots. P3V2 App Service plan with a single instance (2 CPUs, 7 GB memory). Standard Azure Database tier (100 DTUs, 10 GB size).

## Medium deployment (<500 robots)

[![Deploy to Azure](https://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FUiPath%2FDevOps%2Ffeature%2Forchestrator_arm_templates%2FARM%2Fuipath-orchestrator%2Fazuredeploy.medium.json)

Supports up to 500 connected robots. P3V2 App Service plan with 2 instances (4 CPUs, 14 GB memory each). Standard Azure Database tier (200 DTUs, 100 GB size).

## Large deployment (<1k robots)

[![Deploy to Azure](https://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FUiPath%2FDevOps%2Ffeature%2Forchestrator_arm_templates%2FARM%2Fuipath-orchestrator%2Fazuredeploy.large.json)

Supports up to 1k connected robots. P3V2 App Service plan with 4 instances (4 CPUs, 14 GB memory each). Premium Azure Database tier (1000 DTUs, 500 GB size).
