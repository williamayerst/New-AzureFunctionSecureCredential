write-output "Adding in DLL's"
Add-Type -Path "D:\home\site\wwwroot\Put-SPOData\bin\Microsoft.SharePoint.Client.dll"
Add-Type -Path "D:\home\site\wwwroot\Put-SPOData\bin\Microsoft.SharePoint.Client.Runtime.dll"

write-output "Pulling data from App Settings via Environment variables..."
$username = $env:SPUsername
$password = $env:SPUserpass
$url = $env:SPUrl
$listTitle = $env:SPListTitle

write-output "Setting Encryption Key Data..."

$keypath = "D:\home\site\wwwroot\Put-SPOData\PassEncryptKey.key"

write-output "Converting App Setting encrypted PW to PSCredential..."
$secpassword = $password | ConvertTo-SecureString -key (Get-content $keypath)
$credential = New-Object System.Management.Automation.PSCredential ($username, $secpassword)

### debugging bullshit ###
if (test-path $keypath) {write-output "key found"} else {write-output "key not found"}
write-output "@@@@ keypath $keypath"
write-output "@@@@ password $password"
write-output "@@@@ secpassword $secpassword"
write-output "@@@@ username $($credential.username)"
### debugging bullshit ###

<#
write-output "Setting SPO Context"
$context =  New-Object Microsoft.SharePoint.Client.ClientContext($Url)

write-output "Setting SPO Creds"
$context.Credentials = $credential

write-output "Doing Magical Sharepoint Things...."
$list = $context.Web.Lists.GetByTitle($listTitle)
$context.Load($list.RootFolder)
$context.ExecuteQuery()
$listUrl = $list.RootFolder.ServerRelativeUrl

write-output "List Relative Url: " $listUrl
#>
