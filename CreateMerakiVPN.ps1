$sharedkey = 
$VPNConnectName = 
$ServerAddress = 
$TunnelType = 'L2tp'
$AuthMethod = @('Pap')
$EncryptionLevel = 'Optional'
$RememberCredential = $true
$SplitTunnel = $false
$rasphone = "$env:APPDATA\Microsoft\Network\Connections\Pbk\rasphone.pbk"
$badinterfacemetric = 'IpInterfaceMetric=0'
$goodinterfacemetric = 'IpInterfaceMetric=1'
$dnssuffix = 
$IdleDisconnect = "1800"
$vpnIconUrl = 
$vpnIconName = "$env:USERPROFILE\Downloads\VPN.ico"
$DesktopShortcut = "$env:USERPROFILE\Desktop\VPN.lnk"

#If you want to download an icon for the desktop shortcut, uncomment this line
#Invoke-WebRequest -Uri $vpnIconLocation -OutFile $vpnIconName

# If there's no existing VPNs, rasphone.pbk may not already exist
# If it does not exist, then create an empty placeholder.
# Placeholder will be overwritten when new VPN is created.
# Change $env:PROGRAMDATA to $env:APPDATA for single user connection

If ((Test-Path $rasphone) -eq $false) {
    $PbkFolder = "$env:APPDATA\Microsoft\Network\Connections\pbk\"
    if ((Test-Path $PbkFolder) -eq $true){
        New-Item -path $PbkFolder -name "rasphone.pbk" -ItemType "file" | Out-Null
    }
    else{
        $ConnectionFolder = "$env:PROGRAMDATA\Microsoft\Network\Connections\"
        New-Item -path $ConnectionFolder -name "pbk" -ItemType "directory" | Out-Null
        New-Item -path $PbkFolder -name "rasphone.pbk" -ItemType "file" | Out-Null
    }
}

#Remove Any Old VPN Connection
Remove-VpnConnection -Name $VPNConnectName -Force -PassThru

#Create VPN Connection
Add-VpnConnection -Name $VPNConnectName -ServerAddress $ServerAddress -TunnelType $TunnelType -AuthenticationMethod $AuthMethod -EncryptionLevel Optional -L2tpPsk $sharedkey -DnsSuffix $dnssuffix -Force -WA SilentlyContinue
Start-Sleep -Milliseconds 200

#Set Additional Settings
Set-VpnConnection -Name $VPNConnectName -SplitTunneling $SplitTunnel -RememberCredential $RememberCredential -IdleDisconnectSeconds $IdleDisconnect
Start-Sleep -Milliseconds 200

#Change DNS Suffix Options
Set-VpnConnectionTriggerDnsConfiguration -ConnectionName "$VPNConnectName" -DnsSuffixSearchList $dnssuffix -PassThru -Force
Start-Sleep -Milliseconds 200

#Set Interface Metric
(Get-Content $rasphone) -replace $badinterfacemetric, $goodinterfacemetric | set-content $rasphone
Start-Sleep -Milliseconds 200

#Route 192.168.1.0/24 Through the newly created VPN - Fringe UseCase Scenario
#Add-VpnConnectionRoute -ConnectionName $VPNConnectName -DestinationPrefix 192.168.1.0/24

#Create Desktop Shortcut on User Desktop
#If Shortcut Exists, Delete it
If (Test-Path $DesktopShortcut)
{
 Remove-Item $DesktopShortcut
}
#Create new shortcut in User Desktop
$TargetFile = "$env:SystemRoot\System32\rasphone.exe"
$ShortcutFile = $DesktopShortcut
$WScriptShell = New-Object -ComObject WScript.Shell
$Shortcut = $WScriptShell.CreateShortcut($ShortcutFile)
$Shortcut.TargetPath = $TargetFile
$Shortcut.IconLocation = "$env:USERPROFILE\Downloads\VPN.ico,0"
$Shortcut.Save()


#To End With Reboot Warning, Uncommend the following lines
#clear
#echo "The VPN Has been configured."
#echo "If using a mobile hotspot, a reboot might be required before you can connect"
#echo "Press any key to exit..."
#$Host.UI.RawUI.ReadKey("NoEcho,IncludekeyDown")