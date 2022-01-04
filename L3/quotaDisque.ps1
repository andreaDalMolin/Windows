# &"fsutil" "quota" "modify" "volume" "warning" "limit" "user"
# $resultat = &"fsutil" "quota" "modify" "C:" "40000000" "50000000" "BOUBOU"

<# Prendre le fichier #>
$content = Get-Content -Path "C:\Scripts\listeEx2.csv"

foreach($line in $content){
    # Vérification de la ligne
    if($line -match '^(\w+);(\w+);(\w+);(\w+);(\w+)'){
        $departement = $($Matches[5])

                # Création de la catégorie si celle-ci n'existe pas
        try {
            $group = Get-LocalGroup -Name $departement -ErrorAction:Stop
            Write-Output "Found a group with this name already"
        }
        catch {
            Write-Output "$departement was not found, creating the group"
            $group = New-LocalGroup -Name "$departement" -Description "Groupe de membres de la categorie $departement"
        }

        
        # Création de l'utilisateur
        $user = New-LocalUser -AccountNeverExpires -PasswordNeverExpires `
            -FullName "$($Matches[3]) $($Matches[2])" -name "$($Matches[2])" `
            -Password (ConvertTo-SecureString -AsPlainText "$($Matches[4])" -Force) `
            -UserMayNotChangePassword
        # Assignation d'un groupe à un utilisateur
        Add-LocalGroupMember -Group "Users" -Member $user
        Add-LocalGroupMember -Group "$departement" -Member $user

        <# Section ADSI #>
        $userADSI = [ADSI] "WinNT://$env:computername/$($Matches[2])"
        $userADSI.Profile = "C:\UserData\$($Matches[2])\myprofile"
        $userADSI.HomeDirectory = "C:\UserData\$($Matches[2])"
        $userADSI.SetInfo()

        # Création des dossiers d'un utilisateur
        mkdir -p C:\UserData\$($Matches[2])
        mkdir -p C:\UserData\$($Matches[2])\myprofile.V6

        # Donner le controle total à l'utilisateur
        $totalControl = &"icacls" "C:\UserData\$($Matches[2])" "/grant" "$($Matches[2]):(OI)(CI)(F)"
        
        if($departement -eq "administratif" -or $departement -eq "social" -or $departement -eq "comptabilite" -or $departement -eq "direction"){
            Write-Output "member of Administratif, social, comptabilité or direction"
            $resultat = &"fsutil" "quota" "modify" "C:" "390000000" "400000000" "$($Matches[2])"

        }elseif($departement -eq "elearning"  -or $departement -eq "etudiant" -or $departement -eq "juridique" -or $departement -eq "travaux"){
            Write-Output "member of E-Learning, etudiant, juridique et travaux"
            $resultat = &"fsutil" "quota" "modify" "C:" "290000000" "300000000" "$($Matches[2])"
            
        }elseif($departement -eq "informatique"  -or $departement -eq "communication" -or $departement -eq "personnel"){
            Write-Output "member of Informatique, communication et personnel"
            $resultat = &"fsutil" "quota" "modify" "C:" "750000000" "800000000" "$($Matches[2])"
        }


    }
}