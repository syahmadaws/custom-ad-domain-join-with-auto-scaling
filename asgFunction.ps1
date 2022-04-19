#Requires -Modules @{ModuleName='AWS.Tools.Common';ModuleVersion='4.1.66.0'}
#Requires -Modules @{ModuleName='AWS.Tools.EC2';ModuleVersion='4.1.66.0'}
#Requires -Modules @{ModuleName='AWS.Tools.AutoScaling';ModuleVersion='4.1.66.0'}
#Requires -Modules @{ModuleName='AWS.Tools.SimpleSystemsManagement';ModuleVersion='4.1.66.0'}

$split = $LambdaInput -split ","
$instanceId = $split[0]
$asgLifeCycleTransition = $split[1]
$region = $split[2]

Set-DefaultAWSRegion -Region $region

if ($asgLifeCycleTransition -eq "autoscaling:EC2_INSTANCE_LAUNCHING") {
    Write-Host "Auto Scaling is launching an instance, execute AD domain join."
    $s3Key = "JoinToDomain.ps1"
}

if ($asgLifeCycleTransition -eq "autoscaling:EC2_INSTANCE_TERMINATING") {
    Write-Host "Auto Scaling is terminate an instance, execute AD domain unjoin."
    $s3Key = "UnjoinFromDomain.ps1"
}

#Start-Sleep -Seconds 10
Write-Host "Performing domain join/unjoin activity."
Write-Host "Polling get status of the instance, please wait."

$filter = @{Key="InstanceIds";ValueSet=$instanceId}

while ($status.AssociationStatus -ne "Success") {
   Start-Sleep -Seconds 5
   $status = (Get-SSMInstanceInformation -InstanceInformationFilterList $filter -Region $region) 
}

Send-SSMCommand -DocumentName "AWS-RunRemoteScript" -InstanceIds $instanceId -Parameter @{sourceType='S3';sourceInfo="{`"path`": `"https://syahmad-ssm1-demo.s3.us-east-2.amazonaws.com/PowerShell/Scripts/$s3Key`"}";commandLine=".\$s3Key"} -Verbose

Clear-DefaultAWSRegion
