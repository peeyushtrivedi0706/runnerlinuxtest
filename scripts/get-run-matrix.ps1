param (
    [string]$environment,
    [string]$appName,
    [string]$region
)
 
$targetMachines = @()

 
# Function to fetch and process instances
function Get-Instances {
    param (
        [string]$filterQuery
    )
    $targetMachines = @()
    # Fetch instance IDs and names using the filter
    $instancesJson = aws ec2 describe-instances --filters "Name=tag:Name,Values=${filterQuery}" --query 'Reservations[].Instances[].[InstanceId, Tags[?Key==`Name`].Value]' --output json

    $instances = $instancesJson | ConvertFrom-Json
 
    # Process each instance
    foreach ($instance in $instances) {
        $instance_id = $instance[0]
        $name_tag = $instance[1]
 
        # Fetch computer names from AWS SSM
        $ComputerNames = aws ssm describe-instance-information --instance-information-filter-list key=InstanceIds,valueSet=$instance_id --query 'InstanceInformationList[0].ComputerName' --output text --region $region
 
        # Add to target machines
        foreach ($ComputerName in $ComputerNames) {
            if ($ComputerName) {
                # $ComputerName = $ComputerName.Split('.')[0]
                $targetMachines += '"'+$ComputerName +'"'
            } else {
                Write-Host "Warning: No computer name found for InstanceId: $instance_id"
            }
        }
    }
    return $targetMachines
}

$inventoryJson= Get-Content -Path "scripts\target.json" -Raw
$inventory = $inventoryJson | ConvertFrom-Json
$environmentInventory = $inventory | Where-Object {$_.environment -eq $environment }
$tagInventory = $environmentInventory.applications | Where-Object {$_.name -eq $appName }
$service = $tagInventory.serviceTagName -split ","
# Build the filter query
$instanceTags=$environmentInventory.instanceIdentifier | Where-Object{$_.serviceTagName -in $service}

foreach ($instance in $instanceTags) {
    foreach ($instanceTag in $instance.instanceTag) {
        # $filterQuery += " Name=name:ServiceTag,Values=$($instanceTag.name)*"
        # Fetch and process instances
        Write-Output "Processing: $($instanceTag.name)"
        $targetMachines += Get-Instances -filterQuery $instanceTag.name
    
        # Prepare the final output
        if ($targetMachines.Count -eq 0) {
            Write-Host "No target machines found."
        } else {
            $jo = "[" + ($targetMachines -join ", ") + "]"
            Write-Host "Target Machines JSON: $jo"
            
            # Output for GitHub Actions
            Write-Output "ServiceTag=$tagInventory.serviceTagName" >> $env:GITHUB_OUTPUT
            Write-Output "Target=$jo" >> $env:GITHUB_OUTPUT
            Write-Host "GitHub Output Saved."
        }
    } 
}
