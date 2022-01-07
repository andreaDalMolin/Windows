$dc = "cg01-dom"

try{
   Get-ADOrganizationalUnit -Identity "OU=CGUsers,DC=$dc,DC=local" | Out-Null
   Write-Output "CGUsers already exists, skipping ahead..."
}
catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]{
    Write-Output "Creating OU CGUsers..."
    New-ADOrganizationalUnit –Name "CGUsers" –Path "DC=$dc,DC=local" -ProtectedFromAccidentalDeletion $false
}

<# Prendre le fichier #>
$content = Get-Content -Path "C:\Scripts\listeEx2.csv"

foreach($line in $content){
    # Vérification de la ligne
    if($line -match '^(\w+);(\w+);(\w+);(\w+);(\w+)'){
        $departement = $($Matches[5])
        $login = $($Matches[1])
        $password = $($Matches[4])
        $fname = $($Matches[3])
        $lname = $($Matches[2]).ToUpper()
        $displayName = $($Matches[3]) + " " + $($Matches[2]).ToUpper()
        
        try{
            Get-ADOrganizationalUnit -Identity "OU=$departement,OU=CGUsers,DC=$dc,DC=local" | Out-Null
            Write-Output "$departement already exists, skipping ahead..."
        }
        catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]{
            Write-Output "Creating sub-OU $departement..."
            New-ADOrganizationalUnit –Name "$departement" –Path "OU=CGUsers,DC=$dc,DC=local" -ProtectedFromAccidentalDeletion $false
        }

        try{
            Get-ADGroup -Identity $departement | Out-Null
            Write-Output "$departement security group already exists, skipping ahead..."
        }
        catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]{
            Write-Output "Creating $departement security group..."
            New-ADGroup –Name "$departement" –samAccountName $departement `
            -GroupCategory Security –GroupScope Global `
            -Path "OU=$departement,OU=CGUsers,DC=$dc,DC=local"
        }

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
                –SamAccountName $login -UserPrincipalName $login@dalmolin.local `
                –Path "OU=$departement,OU=CGUsers,DC=$dc,DC=local" –GivenName "$fname" `
                -Surname "$lname" –DisplayName "$displayName" `
                -ProfilePath "\\SRV2016-1\CGData\%USERNAME%\netprofile" `
                -HomeDirectory "\\SRV2016-1\CGData\$login" `
                -HomeDrive "P:"

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
        
        Add-ADGroupMember "CN=$departement,OU=$departement,OU=CGUsers,DC=$dc,DC=local" -Members "CN=$login,OU=$departement,OU=CGUsers,DC=$dc,DC=local"
        
    }
}