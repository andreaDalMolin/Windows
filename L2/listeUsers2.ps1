<# Lire le contenu du fichier #>
$content = Get-Content -Path "C:\Scripts\liste-users.csv"
foreach($line in $content){
    if($line -match '^(\w+);(\w+);(\w+)'){
        $departement = $($Matches[3])
        $login = $departement.Substring(0,1) + $departement.Substring($departement.Length-1)
        
        if ($departement -eq $currentDepartment) {
            $sectionNumber++
        }
        else {
            $currentDepartment = $($Matches[3])
            $sectionNumber = 1
        }
        $login += '{0:d4}' -f $sectionNumber


        #Génération du mdp
        $pass = ""
        if('{0:d4}' -f $sectionNumber -eq "0050"){ $pass = "P@ssw0rd" }
        else{
            for($i=0; $i -lt 2; $i++) { $pass += [char](Get-Random -Maximum 57 -Minimum 48) }
            for($i=0; $i -lt 2; $i++) { $pass += [char](Get-Random -Maximum 90 -Minimum 65) }
            for($i=0; $i -lt 2; $i++) { $pass += [char](Get-Random -Maximum 122 -Minimum 97) }
            $pass = ($pass.toCharArray() | Sort-Object {Get-Random}) -join ""
        }
        
        Write-Output "$login;$($Matches[1]);$($Matches[2]);$pass;$($Matches[3])"
    }
}