$hostname = hostname
Write-Host "Running on host: $hostname"
# Write-Host "Running on host: $hostname" > C:\test.txt
Write-Host "Path"
pwd
Write-Host "list files"
dir
Write-Host "current user info"
Get-LocalUser | Where-Object { $_.Name -eq $env:USERNAME }
whoami /user
$env:USERNAME
Get-WmiObject -Class Win32_ComputerSystem | Select-Object -Property UserName