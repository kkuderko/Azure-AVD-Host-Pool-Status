<#
Pre-requisites:
On the PRTG server install Azure PowerShell

 Install-Module Az

Check if installation succeeded

 Get-command *AzAccount* -Module *Az*

Check for TLS 1.2 support

 [Net.ServicePointManager]::SecurityProtocol

Should display Tls, Tls11, Tls12, Tls13 - if not add the below registry

 Set-ItemProperty -Path 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NetFramework\v4.0.30319' -Name 'SchUseStrongCrypto' -Value '1' -Type DWord
 Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\.NetFramework\v4.0.30319' -Name 'SchUseStrongCrypto' -Value '1' -Type DWord

Azure username/password auth has been removed from Azure PowerShell so use service principals https://docs.microsoft.com/en-us/powershell/azure/authenticate-azureps?view=azps-6.6.0
Basically, add new app registration in Azure, grant it Reader role to your subscription and use app secret to connect in the script

Command line syntax

 .\AzureAVDHostPoolStatus.ps1 -AppID <AppID> -AppSecret <AppSecret> -TenantID <TenantID> -Subscription <SubscriptionID> -HostPool <Host Pool name> -ResourceGroup <Resource group name>

Example PRTG parameters syntax

 -AppID "12345678-1234-1234-1234-123456789012" -AppSecret "J^27dFTEoLSB67hs0IL" -TenantID "12345678-1234-1234-1234-123456789012" -Subscription "12345678-1234-1234-1234-1234567890121" -HostPool "AVD-Production" -ResourceGroup "AzureVirtualDesktop-RG"

#>


# variables
#$ErrorActionPreference = 'silentlycontinue'
param ($AppID,$AppSecret,$TenantID,$Subscription,$HostPool,$ResourceGroup)
$AvailableHosts = 0

# Azure connect
Disable-AzContextAutosave | Out-Null
$AppSecret = ConvertTo-SecureString -String $AppSecret -AsPlainText -Force
$pscredential = New-Object -TypeName System.Management.Automation.PSCredential($AppID,$AppSecret)
Connect-AzAccount -ServicePrincipal -Credential $pscredential -Tenant $TenantId | Out-Null
$Context = Get-AzSubscription -SubscriptionId $Subscription
Set-AzContext $Context | Out-Null

# get host pool status
$AVDHostList = Get-AzWvdSessionHost -ResourceGroupName $ResourceGroup -HostPoolName $HostPool
$TotalAVDHosts = ($AVDHostList).count
$TotalAVDSessions = ($AVDHostList | Select-Object Session | Measure-Object -Property Session -Sum).Sum
$HostPoolSessionLimit = (Get-AzWvdHostPool -ResourceGroupName $ResourceGroup -Name $HostPool).MaxSessionLimit

foreach ($AVDHost in $AVDHostList){
	if ($AVDHost.Status -eq "Available") {
		$AvailableHosts ++
	}
}

$CurrentSessionLimit = $HostPoolSessionLimit * $AvailableHosts
$SessionCapacityP = [math]::ceiling(($TotalAVDSessions*100)/($CurrentSessionLimit))

# sensor XML format
$XMLResult = @"
<prtg>

 <result>
  <channel>Hosts Available</channel>
  <value>$AvailableHosts</value>
  <LimitMinError>0.1</LimitMinError>
  <LimitMode>1</LimitMode>
 </result>

 <result>
  <channel>Total Hosts in the Pool</channel>
  <value>$TotalAVDHosts</value>
 </result>

 <result>
  <channel>Active Sessions</channel>
  <value>$TotalAVDSessions</value>
 </result>

 <result>
  <channel>Session Limit</channel>
  <value>$CurrentSessionLimit</value>
 </result>

 <result>
  <channel>Session Usage</channel>
  <value>$SessionCapacityP</value>
  <unit>Percent</unit>
  <LimitMaxError>95</LimitMaxError>
  <LimitMaxWarning>75</LimitMaxWarning>
  <LimitMode>1</LimitMode> </result>
</prtg>
"@

# display output
Write-Host $XMLResult
Disconnect-AzAccount | Out-Null