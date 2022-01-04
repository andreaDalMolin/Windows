<# Prendre le fichier #>
$content = Get-Content -Path "C:\Scripts\listeEx2.csv"

foreach($line in $content){
    # Vérification de la ligne
    if($line -match '^(\w+);(\w+);(\w+);(\w+);(\w+)'){
        Write-Output "Removing $($Matches[2])"
        Remove-LocalUser -Name "$($Matches[2])"

        Write-Output "Removing $($Matches[2]) UserData folder...)"
        Remove-Item C:\UserData\$($Matches[2]) -Recurse

    }
}