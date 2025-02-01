param (
        [string]$tagname,
        $env
		
)
[array]$targetmachine=@()
if($tagname -eq "RCM-AHI.APP.LEGACY") {
              if($env -eq "prod") {
                $targetmachine = "i-0b1d3c4e2a5f7e9b6 - imp_app_aps_server-1 #Production"
                $targetmachine += "i-0b1d3c4e2a5f7e9b6 - imp_app_aps_server-2 #Production"
                $targetmachine += "i-0b1d3c4e2a5f7e9b6 - imp_app_aps_server-3 #Production"
              } elseif ($env -eq "dev") {
                $targetmachine = "i-0b1d3c4e2a5f7e9b6 - imp_app_aps_server-1 #Development"
              } elseif ($env -eq "qa") {
                $targetmachine = "i-0b1d3c4e2a5f7e9b6 - imp_app_aps_server-1 #QA"
              } elseif ($env -eq "mock") {
                $targetmachine = "i-0b1d3c4e2a5f7e9b6 - imp_app_aps_server-1 #Mock"
              }
            } elseif ($tagname -eq "RCM-AHI.APP.PHASE2") {
              if($env -eq "prod") {
                $targetmachine = "i-0b1d3c4e2a5f7e9b6 - imp_app_aps_server-1 #Production RCM-AHI.APP.PHASE2"
                $targetmachine += "i-0b1d3c4e2a5f7e9b6 - imp_app_aps_server-2 #Production RCM-AHI.APP.PHASE2"
              } elseif ($env -eq "dev") {
                $targetmachine = "i-0b1d3c4e2a5f7e9b6 - imp_app_aps_server-1 #Development RCM-AHI.APP.PHASE2"
              } elseif ($env -eq "qa") {
                $targetmachine = "i-0b1d3c4e2a5f7e9b6 - imp_app_aps_server-1 #QA RCM-AHI.APP.PHASE2"
              } elseif ($env -eq "mock") {
                $targetmachine = "i-0b1d3c4e2a5f7e9b6 - imp_app_aps_server-1 #Mock RCM-AHI.APP.PHASE2"
                $targetmachine += "i-0b1d3c4e2a5f7e9b6 - imp_app_aps_server-2 #Mock RCM-AHI.APP.PHASE2"
              }
            }
			echo ($targetmachine | ConvertTo-Json)
			$joinedString = ($targetmachine -join ',') | ConvertTo-Json
			 $joinedString
			 $objects = $targetmachine | ForEach-Object {
    [PSCustomObject]@{
        target = $_
    }
}

# Convert the array of objects to JSON
$json = '{"include":'+($objects | ConvertTo-Json)+'}'

# Output the JSON
$json
echo "::set-output name=targetmachine::$json"
