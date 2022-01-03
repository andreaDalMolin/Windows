<# Prendre le fichier #>
$content = Get-Content -Path "C:\Scripts\listeEx2.csv"

foreach($line in $content){
    # Vérification de la ligne
    if($line -match '^(\w+);(\w+);(\w+);(\w+);(\w+)'){
        $departement = $($Matches[5])
        
        # Création de la catégorie si celle-ci n'existe pas
        if($currentCategory -ne $departement){
            $currentCategory = $departement
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
    }
}