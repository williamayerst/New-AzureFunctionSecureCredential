######################################################
write-output "Creating Sub-Functions for De/Encrypting via KeyFile"
# see : https://gist.github.com/ctigeek/2a56648b923d198a6e60
######################################################
function Create-AesManagedObject($key, $IV) {
  $aesManaged = New-Object "System.Security.Cryptography.AesManaged"
  $aesManaged.Mode = [System.Security.Cryptography.CipherMode]::CBC
  $aesManaged.Padding = [System.Security.Cryptography.PaddingMode]::Zeros
  $aesManaged.BlockSize = 128
  $aesManaged.KeySize = 256
  if ($IV) {
    if ($IV.getType().Name -eq "String") {
      $aesManaged.IV = [System.Convert]::FromBase64String($IV)
    }
    else {
      $aesManaged.IV = $IV
    }
  }
  if ($key) {
    if ($key.getType().Name -eq "String") {
      $aesManaged.Key = [System.Convert]::FromBase64String($key)
    }
    else {
      $aesManaged.Key = $key
    }
  }
  $aesManaged
}

function Create-AesKey() {
  $aesManaged = Create-AesManagedObject
  $aesManaged.GenerateKey()
  [System.Convert]::ToBase64String($aesManaged.Key)
}

function Encrypt-String($key, $unencryptedString) {
  $bytes = [System.Text.Encoding]::UTF8.GetBytes($unencryptedString)
  $aesManaged = Create-AesManagedObject $key
  $encryptor = $aesManaged.CreateEncryptor()
  $encryptedData = $encryptor.TransformFinalBlock($bytes, 0, $bytes.Length);
  [byte[]] $fullData = $aesManaged.IV + $encryptedData
  $aesManaged.Dispose()
  [System.Convert]::ToBase64String($fullData)
}

function Decrypt-String($key, $encryptedStringWithIV) {
  $bytes = [System.Convert]::FromBase64String($encryptedStringWithIV)
  $IV = $bytes[0..15]
  $aesManaged = Create-AesManagedObject $key $IV
  $decryptor = $aesManaged.CreateDecryptor();
  $unencryptedData = $decryptor.TransformFinalBlock($bytes, 16, $bytes.Length - 16);
  $aesManaged.Dispose()
  [System.Text.Encoding]::UTF8.GetString($unencryptedData).Trim([char]0)
}
######################################################
write-output "Adding in DLL's for Sharepoint"
Add-Type -Path "D:\home\site\wwwroot\Put-SPOData\bin\Microsoft.SharePoint.Client.dll"
Add-Type -Path "D:\home\site\wwwroot\Put-SPOData\bin\Microsoft.SharePoint.Client.Runtime.dll"
######################################################
write-output "Setting Encryption Key Data..."
$aeskeypath = "D:\home\site\wwwroot\Put-SPOData\AES.key"
if (test-path $aeskeypath) {write-output "...key found"} else {write-output "...key not found" ; throw }
######################################################
write-output "Converting App Setting encrypted PW to PSCredential..."
$secpassword = $(ConvertTo-SecureString -string $(Decrypt-String $(get-content $aeskeypath) $env:SPUserpass) -AsPlainText -Force)
$credential = New-Object  Microsoft.SharePoint.Client.SharePointOnlineCredentials ($env:SPUsername, $secpassword)
######################################################
write-output "Doing Magical Sharepoint Things...."
write-output "...Setting SPO Context"
$context =  New-Object Microsoft.SharePoint.Client.ClientContext($env:SPUrl)
write-output "...Setting SPO Creds"
$context.Credentials = $credential
write-output "...some other stuff, I guess???"
$list = $context.Web.Lists.GetByTitle($env:SPListTitle)
$context.Load($list.RootFolder)
$context.ExecuteQuery()
$listUrl = $list.RootFolder.ServerRelativeUrl
write-output "List Relative Url: " $listUrl
