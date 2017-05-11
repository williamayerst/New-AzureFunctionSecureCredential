write-host "Pulling data from App Settings via Environment variables..."
$username = $env:SPUsername
$password = $env:SPUserpass
write-host "username is: $username"
write-host "encrypted pw is $password"

#write-host "Setting Encryption Key Data..."
#$keypath = "D:\home\site\wwwroot\PassEncryptKey.key"

#test-path $keypath

#write-host "Converting App Setting encrypted PW to PSCredential..."
#$secpassword = $password | ConvertTo-SecureString -key (Get-content $keypath)
#$credential = New-Object System.Management.Automation.PSCredential ($username, $secpassword)
#
#
#write-host "Got my credential for $($credential.username)!"
