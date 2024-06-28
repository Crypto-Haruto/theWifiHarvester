$wifi = $(netsh.exe wlan show profiles)

if ($wifi -match "There is no wireless interface on the system.") {
    Write-Output $wifi
    exit
}

$ListOfSSID = ($wifi | Select-String -pattern "\w*All User Profile.*: (.*)" -allmatches).Matches | ForEach-Object {$_.Groups[1].Value}
$NumberOfWifi = $ListOfSSID.Count

Write-Host "[$(Get-Date)] I've found $NumberOfWifi Wi-Fi Connection settings stored on your system ($env:computername):"

foreach ($SSID in $ListOfSSID) {
    try {
        $passphrase = ($(netsh.exe wlan show profiles name="$SSID" key=clear) | Select-String -pattern ".*Key Content.*: (.*)" -allmatches).Matches | ForEach-Object {$_.Groups[1].Value}
        $signalStrength = ($(netsh.exe wlan show interfaces | Select-String -pattern "Signal.*: (.*)" -allmatches).Matches | ForEach-Object {$_.Groups[1].Value})[0]
        $securityType = ($(netsh.exe wlan show profiles name="$SSID" key=clear) | Select-String -pattern "Authentication.*: (.*)" -allmatches).Matches | ForEach-Object {$_.Groups[1].Value}
        $channel = ($(netsh.exe wlan show interfaces | Select-String -pattern "Channel.*: (.*)" -allmatches).Matches | ForEach-Object {$_.Groups[1].Value})[0]
    } catch {
        $passphrase = "N/A"
        $signalStrength = "N/A"
        $securityType = "N/A"
        $channel = "N/A"
    }
    Write-Host "$SSID : Passphrase= $passphrase, Signal Strength= $signalStrength, Security Type= $securityType, Channel= $channel"
    Write-Host ""  # Add an empty line for spacing
}
