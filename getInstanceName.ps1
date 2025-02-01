param (
        [string]$tagname,
        $env
		
)
[array]$targetmachine=@()
if($tagname -eq "RCM-AHI.APP.LEGACY") {
              if($env -eq "prod") {
                $targetmachine = "imp_app_aps_server-1"
                $targetmachine += "imp_app_aps_server-2"
                $targetmachine += "imp_app_aps_server-3"
              } elseif ($env -eq "dev") {
                $targetmachine = "mp_app_aps_server-1#Development"
              } elseif ($env -eq "qa") {
                $targetmachine = "mp_app_aps_server-1#QA"
              } elseif ($env -eq "mock") {
                $targetmachine = "mp_app_aps_server-1#Mock"
              }
            } elseif ($tagname -eq "RCM-AHI.APP.PHASE2") {
              if($env -eq "prod") {
                $targetmachine = "mp_app_aps_server-1RCM-AHI.APP.PHASE2"
                $targetmachine += "mp_app_aps_server-2RCM-AHI.APP.PHASE2"
              } elseif ($env -eq "dev") {
                $targetmachine = "mp_app_aps_server-1#DevelopmentRCM-AHI.APP.PHASE2"
              } elseif ($env -eq "qa") {
                $targetmachine = "mp_app_aps_server-1#QARCM-AHI.APP.PHASE2"
              } elseif ($env -eq "mock") {
                $targetmachine = "mp_app_aps_server-1#MockRCM-AHI.APP.PHASE2"
                $targetmachine += "mp_app_aps_server-2#MockRCM-AHI.APP.PHASE2"
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
