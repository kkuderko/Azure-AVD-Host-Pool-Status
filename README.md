# Azure-AVD-Host-Pool-Status
Azure Virtual Desktop Host Pool Status PRTG Sensor

A PowerShell script which can be used for PRTG sensor to display the AVD Host Pool status.
It measures:
- number of active sessions
- how many hosts is available
- what is the current session limit
- what is the current session usage (%)

It takes host pool autoscaling under consideration so there's has to be at least one host available in the pool (alert on 0 hosts) and the session usage percentage is measured depending how many hosts is online.
Session usage will show warning status when 75% capacity has been reached and down status when 95%

All pre-requisites and syntax are described in the script's comments

# Installation
Place the script in C:\Program Files (x86)\PRTG Network Monitor\Custom Sensors\EXEXML\ on the probe server
and add it as sensor "EXE/Script Advanced" with the Parameters like:
> ###### -AppID "12345678-1234-1234-1234-123456789012" -AppSecret "J^27dFTEoLSB67hs0IL" -TenantID "12345678-1234-1234-1234-123456789012" -Subscription "12345678-1234-1234-1234-1234567890121" -HostPool "AVD-Production" -ResourceGroup "AzureVirtualDesktop-RG"
![](https://github.com/kkuderko/Azure-AVD-Host-Pool-Status/blob/main/img01.png)
