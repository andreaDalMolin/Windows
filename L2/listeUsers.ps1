$list = Get-Content -Path "C:\Users\Administrator\Desktop\liste-users.csv"

foreach($line in $list) {
    # Skip comments
    if($line -match '^#.*$') { continue }
    # $arr = $line -split ";"
    if($line -notmatch '^(.*);(.*);(.*)$') { Write-Output "Error" }
    $login = $Matches[3].toCharArray()
    $login = "$($login[0])$($login[$login.count-1])"

    if($Matches[3] -eq $currentSection) { $currentSectionNb++ }
    else {
        $currentSection = $Matches[3]
        $currentSectionNb = 0
    }
    $number = "{0:d4}" -f [int32]$currentSectionNb
    $login = "$login$number"

    #Password generation
    $password = ""
    if($login -match '^.*50$') {$password = "P@ssw0rd"}
    else{
        for($i=0; $i -lt 2; $i++) { $password += [char](Get-Random -Maximum 57 -Minimum 48) }
        for($i=0; $i -lt 2; $i++) { $password += [char](Get-Random -Maximum 90 -Minimum 65) }
        for($i=0; $i -lt 4; $i++) { $password += [char](Get-Random -Maximum 122 -Minimum 97) }
        $password = ($password.ToCharArray() | Sort-Object {Get-Random}) -join ""
    }

    Write-Output "$login;$($Matches[1]);$($Matches[2]);$password;$($Matches[3])"
}