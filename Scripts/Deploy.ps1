#region Configuration

# THIS SCRIPT IS ONLY SUPPOSED TO BE EXECUTED LOCALLY!!!
# IN THE RELEASE PIPELINE, THE ARM TEMPLATES ARE DEPLOYED DIRECTLY!!!

# BY DEFAULT THE PARAMETER-FILE <<Local.parameters.json>> IS USED WHICH DEPLOYS THE TEST-CONFIGURATION TO DV0

# halt on first error
$ErrorActionPreference = "Stop"
# print Information stream
$InformationPreference = "Continue"

# if executed from PowerShell ISE
if ($psise) { 
	$rootPath = Split-Path -Parent $psise.CurrentFile.FullPath | Split-Path -Parent
}
else {
	$rootPath = (Get-Item $PSScriptRoot).Parent.FullName
}
Push-Location $rootPath

if(-not $azContext)
{
	$azContext = Connect-AzAccount
}

if(-not $subscription)
{
	$subscription = Get-AzSubscription | Out-GridView -OutputMode Single -Title "Select Subscription"
	Set-AzContext -SubscriptionObject $subscription
}

if(-not $resourceGroup)
{
	$resourceGroup = Get-AzResourceGroup | Out-GridView -OutputMode Single -Title "Select ResourceGroup"
}

if(-not $templateFolder)
{
	$templateFolder = Get-ChildItem -Path $rootPath -Directory | Out-GridView -OutputMode Single -Title "Select Project to deploy"
}

$templateFile = Join-Path -Path $templateFolder.FullName -ChildPath "azuredeploy.json"
$templateParameterFile = $templateFile.Replace(".json", ".parameters.json")

#Deploy template 
$deployment = New-AzResourceGroupDeployment -Name "Manual_Deployment_$($templateFolder.Name)" `
													-ResourceGroupName $resourceGroup.ResourceGroupName `
													-TemplateFile $templateFile `
													-TemplateParameterFile $templateParameterFile `
													-ApiVersion "2017-05-10" `
													-Force -Verbose
													
if($deployment.ProvisioningState -eq "Failed")
{
  
}

