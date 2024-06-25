$wifi = $(netsh.exe wlan show profiles)

if ($wifi -match "There is no wireless interface on the system.") {
    Write-Output $wifi
    exit
}

$ListOfSSID = ($wifi | Select-String -pattern "\w*All User Profile.*: (.*)" -allmatches).Matches | ForEach-Object {$_.Groups[1].Value}
$NumberOfWifi = $ListOfSSID.Count

Write-Warning "[$(Get-Date)] I've found $NumberOfWifi Wi-Fi Connection settings stored on your system ($env:computername):"

foreach ($SSID in $ListOfSSID) {
    try {
        $passphrase = ($(netsh.exe wlan show profiles name="$SSID" key=clear) | Select-String -pattern ".*Key Content.*: (.*)" -allmatches).Matches | ForEach-Object {$_.Groups[1].Value}
    } catch {
        $passphrase = "N/A"
    }
    Write-Output "$SSID : $passphrase"
}