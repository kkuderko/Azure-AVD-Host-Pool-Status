# Azure-AVD-Host-Pool-Status
###### Azure Virtual Desktop host pool status script and PRTG Sensor

PowerShell script which can be used to display the AVD Host Pool status or create a PRTG (https://www.paessler.com/prtg) sensor.
It measures:
- number of active sessions
- how many hosts is available
- (new) how many hosts in drain mode
- what is the current session limit
- what is the current session usage (%)

It takes host pool autoscaling under consideration so there has to be at least one host available in the pool (alert on 0 hosts) and the session usage percentage is measured depending how many hosts is online.
Session usage will show warning status when 75% capacity has been reached and down status when 95%.
Technically, this should never happen if you have autoscaling setup properly so it would have powered on additional host but you never know, hence the monitoring.
This will also alert when there's no more hosts to power on and total session limit has been almost reached.
The sensor will also display warning if any of the hosts is in a drain mode.

You could use the script [AzureAVDHostPoolStatus-cmd.ps1](https://github.com/kkuderko/Azure-AVD-Host-Pool-Status/blob/main/AzureAVDHostPoolStatus-cmd.ps1) interactively, to simply report the status in the PowerShell like:

![](https://github.com/kkuderko/Azure-AVD-Host-Pool-Status/blob/main/img03.png)

or automate it as PRTG sensor below:

## Pre-requisites for PRTG server

On the PRTG server install Azure PowerShell

`Install-Module Az`

Check if installation succeeded

`Get-command *AzAccount* -Module *Az*`

If Az module fails to install, check for TLS 1.2 support

`[Net.ServicePointManager]::SecurityProtocol`

Should display Tls, Tls11, Tls12, Tls13 - if not add the below registry

`Set-ItemProperty -Path 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NetFramework\v4.0.30319' -Name 'SchUseStrongCrypto' -Value '1' -Type DWord`

`Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\.NetFramework\v4.0.30319' -Name 'SchUseStrongCrypto' -Value '1' -Type DWord`

Azure username/password auth has been removed from Azure PowerShell so use service principals https://docs.microsoft.com/en-us/powershell/azure/authenticate-azureps?view=azps-6.6.0

Basically, add new app registration in Azure, grant it Reader role to your subscription and use app secret in the sensor parameters to connect script to Azure

## Sensor installation
Place the script [AzureAVDHostPoolStatus.ps1](https://github.com/kkuderko/Azure-AVD-Host-Pool-Status/blob/main/AzureAVDHostPoolStatus.ps1) in C:\Program Files (x86)\PRTG Network Monitor\Custom Sensors\EXEXML\ on the probe server
and add it as sensor "EXE/Script Advanced" with the Parameters like:
> ###### -AppID "12345678-1234-1234-1234-123456789012" -AppSecret "J^27dFTEoLSB67hs0IL" -TenantID "12345678-1234-1234-1234-123456789012" -Subscription "12345678-1234-1234-1234-1234567890121" -HostPool "AVD-Production" -ResourceGroup "AzureVirtualDesktop-RG"
![](https://github.com/kkuderko/Azure-AVD-Host-Pool-Status/blob/main/img01.png)

![](https://github.com/kkuderko/Azure-AVD-Host-Pool-Status/blob/main/img02.png)
