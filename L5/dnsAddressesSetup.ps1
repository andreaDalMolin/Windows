$min = 150;
$max = 156;
$serverName = ""
$domainName = "dalmolin.local"
$entryName = "ip-192-168-190-"
$ip = "192.168.190."
$inverseIp = "190.168.192.in-addr.arpa"

for($i=$min; $i -lt $max; $i++) {
    # Ajout dans la zone directe
    $resultat = &"dnscmd" "$serverName" "/RecordAdd" "$domainName" "$entryName$i" "A" "192.168.190.$i"    # Ajout dans la zone inverse    $resultat = &"dnscmd" "$serverName" "/RecordAdd" "$inverseIp" "$i" "PTR" "$entryName$i.$domainName"
}