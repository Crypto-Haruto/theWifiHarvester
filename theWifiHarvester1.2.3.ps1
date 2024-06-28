$wifi = $(netsh.exe wlan show profiles)

if ($wifi -match "There is no wireless interface on the system.") {
    Write-Output $wifi
    exit
}

$ListOfProfiles = ($wifi | Select-String -pattern "\w*All User Profile.*: (.*)" -allmatches).Matches | ForEach-Object {$_.Groups[1].Value}
$NumberOfProfiles = $ListOfProfiles.Count

Write-Host "[$(Get-Date)] Found $NumberOfProfiles Wi-Fi profiles stored on your system ($env:computername):"

# Sort the profiles alphabetically
$SortedProfiles = $ListOfProfiles | Sort-Object

foreach ($Profile in $SortedProfiles) {
    try {
        $SSID = $Profile
        $passphrase = ($(netsh.exe wlan show profiles name="$SSID" key=clear) | Select-String -pattern ".*Key Content.*: (.*)" -allmatches).Matches | ForEach-Object {$_.Groups[1].Value}
        $signalStrength = ($(netsh.exe wlan show interfaces | Select-String -pattern "Signal.*: (.*)" -allmatches).Matches | ForEach-Object {$_.Groups[1].Value})[0]
        $securityType = ($(netsh.exe wlan show profiles name="$SSID" key=clear) | Select-String -pattern "Authentication.*: (.*)" -allmatches).Matches | ForEach-Object {$_.Groups[1].Value}
        $channel = ($(netsh.exe wlan show interfaces | Select-String -pattern "Channel.*: (.*)" -allmatches).Matches | ForEach-Object {$_.Groups[1].Value})[0]
        $BSSID = ($(netsh.exe wlan show interfaces | Select-String -pattern "BSSID.*: (.*)" -allmatches).Matches | ForEach-Object {$_.Groups[1].Value})[0]
    } catch {
        $passphrase = "N/A"
        $signalStrength = "N/A"
        $securityType = "N/A"
        $channel = "N/A"
        $BSSID = "N/A"
    }
    Write-Host "Profile: $SSID"
    Write-Host "  Passphrase: $passphrase"
    Write-Host "  Signal Strength: $signalStrength"
    Write-Host "  Security Type: $securityType"
    Write-Host "  Channel: $channel"
    Write-Host "  BSSID: $BSSID"
    Write-Host ""  # Add an empty line for spacing
}
