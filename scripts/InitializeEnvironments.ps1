param (
    [string]$environment,
    [string]$targetTag,
    [string]$region
)

# Function to fetch and process instances
function Get-Instances {
    param (
        [string]$filterQuery
    )
    $targetMachines = @()
    # Fetch only the Instance IDs using the filter
    $instancesJson = & "C:\Program Files\Amazon\AWSCLIV2\aws.exe" ec2 describe-instances --filters "Name=tag:Name,Values=${filterQuery}" --query 'Reservations[].Instances[].InstanceId' --output json
    $instanceIds = $instancesJson | ConvertFrom-Json
 
    # Ensure $instanceIds is an array even if only one instance is returned
    if (-not ($instanceIds -is [System.Collections.IEnumerable])) {
        $instanceIds = @($instanceIds)
    }
 
    Write-Host "Instances list: $($instanceIds -join ', ')"
 
    # Process each instance
    foreach ($instance_id in $instanceIds) {
        if ($instance_id -notmatch '^i-[a-f0-9]+$') {
            Write-Host "Skipping invalid or malformed InstanceId: $instance_id"
            continue
        }
 
        Write-Host "Processing Instance: ID = $instance_id"
 
        # Fetch computer names from AWS SSM using valid Instance IDs
        $ComputerNames = & "C:\Program Files\Amazon\AWSCLIV2\aws.exe" ssm describe-instance-information --instance-information-filter-list key=InstanceIds,valueSet=$instance_id --query 'InstanceInformationList[0].ComputerName' --output text --region $region
 
        # Add to target machines if computer names are found
        foreach ($ComputerName in $ComputerNames) {
            if ($ComputerName) {
                $targetMachines += '"' + $ComputerName + '"'
                Write-Host "Target Machine: $ComputerName"
            } else {
                Write-Host "Warning: No computer name found for InstanceId: $instance_id"
            }
        }
    }
    return $targetMachines
}
if($environment -eq "dev" -OR $environment -eq "qa") {
    $targetMachines='"'+"localhost"+'"'
    $jo = "[" + ($targetMachines -join ", ") + "]"
    Write-Host "Target Machines JSON: $jo"
 
    # Output for GitHub Actions
    echo "targetMachines=$jo" >> $env:GITHUB_OUTPUT
    Write-Host "GitHub Output Saved."
} else {
    
# Read target inventory from JSON
$inventoryJson = Get-Content -Path "scripts\target.json" -Raw
$inventory = $inventoryJson | ConvertFrom-Json
$environmentInventory = $inventory | Where-Object { $_.environment -eq $environment }
$tagInventory = $environmentInventory.applications | Where-Object { $_.name -eq $targetTag }
 
foreach ($instanceTag in $tagInventory.instanceNameTag) {
    Write-Host "Filter of InstanceNameTag: $instanceTag"
    $targetMachines = Get-Instances -filterQuery $instanceTag
    if ($targetMachines.Count -eq 0) {
    Write-Host "Target Machine(IF): $targetMachines"
    Write-Host "No target machines found."
    } else {
    $jo = "[" + ($targetMachines -join ", ") + "]"
    Write-Host "Target Machines JSON: $jo"
 
    # Output for GitHub Actions
    echo "targetMachines=$jo" >> $env:GITHUB_OUTPUT
    Write-Host "GitHub Output Saved."
    }
}
}
