
## CREATE KEY

Function New-EncryptKey
{
$AESKey = New-Object Byte[] 32
[Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($AESKey)
Set-Content .\PassEncryptKey.key $AESKey
}

## ENCRYPT PASS WITH KEY

Function Get-EncryptedPassword
{
  param (
    [Parameter(Mandatory=$true,HelpMessage='Please specify password in clear text')][ValidateNotNullOrEmpty()][String]$Password
  )
  $secPw = ConvertTo-SecureString -AsPlainText $Password -Force
  $AESKey = Get-content .\PassEncryptKey.key
  $Encryptedpassword = $secPw | ConvertFrom-SecureString -Key $AESKey
  $Encryptedpassword
}

if (!(test-path .\PassEncryptKey.key)) {New-EncryptKey}

$plain = Read-host "Enter string to encrypt" 
Get-EncryptedPassword $plain | clip
Write-host "encrypted PW now in clipboard"