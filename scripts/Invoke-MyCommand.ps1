param(
    [string]$ComputerName,
    [Parameter]
    [string]$ScriptBlock,
    [string] $FilePath,
    $ArgumentList
    )   
$ScriptBlock = [scriptblock]::Create($ScriptBlock)
# Execute the command locally or remotely
if ($ComputerName -eq "localhost") {  
    if($FilePath -ne $null) {
        if($ArgumentList -ne $null) {
            . $FilePath @ArgumentList
        } else {
            . $FilePath
        }
    } else {
      if($ArgumentList -ne $null) {
            & $ScriptBlock @ArgumentList
        } else {
            & $ScriptBlock
        }
    }     
} else {
    if($FilePath -ne $null) {
        if($ArgumentList -ne $null) {
            Invoke-Command -ComputerName $ComputerName -FilePath $FilePath -ArgumentList $ArgumentList
        } else {
            Invoke-Command -ComputerName $ComputerName -FilePath $FilePath
        }
    } else {
        if($ArgumentList -ne $null) {
            Invoke-Command -ComputerName $ComputerName -ScriptBlock $ScriptBlock -ArgumentList $ArgumentList
        } else {
            Invoke-Command -ComputerName $ComputerName -ScriptBlock $ScriptBlock
        }
    }
}
