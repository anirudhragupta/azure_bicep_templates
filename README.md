# Bicep Templates for NSPI Deployments

`Author: Anirudhra Gupta`

## Commands to Deploy Bicep Files

### Azure PowerShell

Subscription Level Deployment:
```
New-AzSubscriptionDeployment -Location <location> -TemplateFile <path-to-bicep> -TemplateParamterFile <path-to-parameters-json>
```
Resource Group Level Deployment:
```
New-AzResourceGroupDeployment -ResourceGroupName <resource-group-name> -TemplateFile <path-to-bicep> -TemplateParamterFile <path-to-parameters-json>
```

### Azure CLI

Subscription Level Deployment:
```
az deployment sub create --location <location> --template-file <path-to-bicep> --parameters <path-to-parameters-json>
```
Resource Group Level Deployment:
```
az deployment group create --resource-group <resource-group-name> --template-file <path-to-bicep> --parameters <path-to-parameters-json>
```
