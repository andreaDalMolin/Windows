$dc = "cg01-dom"

try{
   Get-ADOrganizationalUnit -Identity "OU=CGUsers,DC=$dc,DC=local" | Out-Null
   Write-Output "CGUsers already exists, skipping ahead..."
}
catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]{
    Write-Output "Creating OU CGUsers..."
    New-ADOrganizationalUnit –Name "CGUsers" –Path "DC=$dc,DC=local" -ProtectedFromAccidentalDeletion $false
}

$login = "helmodom"
$password = "cgdom2016"
$fname = "helmodom"
$displayName = "helmodom"

try {
    Get-ADUser -Identity $login | Out-Null
    Write-Output "$login already exists, skipping ahead..."
} 
catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]{
    Write-Output "Creating user $login..."

    # Création des dossiers d'un utilisateur
    mkdir -p C:\CGData\$($login)
    mkdir -p C:\CGData\$($login)\netprofile.V6

    new-ADUser –Name "$login" –AccountPassword (ConvertTo-SecureString –AsPlainText $password –Force) –Enabled $true `
        -PasswordNeverExpires $true –CannotChangePassword $true `
        –SamAccountName $login -UserPrincipalName $login@swila.local `
        –Path "OU=CGUsers,DC=$dc,DC=local" –GivenName "$fname" `
        –DisplayName "$displayName" `
        -HomeDirectory "C:\CGData\%USERNAME%" `
        -ProfilePath "\\SRV2016-1\CGData\%USERNAME%\netprofile"     

    # Donner le controle total à l'utilisateur
    $currentUser = Get-ADUser -Identity $login
    Write-Output $currentUserSID

    $autorisation = [System.Security.AccessControl.FileSystemRights]"FullControl" 
    $heritage = [System.Security.AccessControl.InheritanceFlags]::ContainerInherit -bor `
        [System.Security.AccessControl.InheritanceFlags]::ObjectInherit
    $propagation = [System.Security.AccessControl.PropagationFlags]::None 
    $decision = [System.Security.AccessControl.AccessControlType]::Allow 
 
    $acl = Get-Acl "C:\CGData\$login"
    $ace = New-Object Security.AccessControl.FileSystemAccessRule($currentUser.SID, $autorisation, $heritage, $propagation, $decision) -ErrorAction:Stop
    $acl.AddAccessRule($ace)
    Set-Acl -Path "C:\CGData\$login" -AclObject $acl -ErrorAction:Stop
}