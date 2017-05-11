write-output "Adding in DLL's"

Add-Type -Path "D:\home\site\wwwroot\TimerTriggerPowerShell1\bin\Microsoft.SharePoint.Client.dll"   
Add-Type -Path "D:\home\site\wwwroot\TimerTriggerPowerShell1\bin\Microsoft.SharePoint.Client.Runtime.dll"   

write-output "Pulling data from App Settings via Environment variables..."

$username = $env:SPUsername
$password = $env:SPUserpass
$Url = "https://ayerst.sharepoint.com"

write-output "username is: $username"
write-output "encrypted pw is $password"
write-output "URL is $password"

write-output "Setting Encryption Key Data..."
$keypath = "D:\home\site\wwwroot\Put-SPOData\PassEncryptKey.key"

test-path $keypath

write-output "Converting App Setting encrypted PW to PSCredential..."
$secpassword = $password | ConvertTo-SecureString -key (Get-content $keypath)
$credential = New-Object System.Management.Automation.PSCredential ($username, $secpassword)


write-output "Got my credential for $($credential.username)!"
