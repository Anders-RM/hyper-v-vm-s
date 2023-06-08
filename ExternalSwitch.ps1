# Define variables
$switchName = "ExternalSwitch"
$switchType = "External"

# Get the network adapter for the external connection
$networkAdapter = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' -and $_.PhysicalMediaType -eq '802.3' } | Select-Object -First 1
$adapterName = $networkAdapter.Name

# Create the switch
New-VMSwitch -Name $switchName -NetAdapterName $adapterName -AllowManagementOS $false -SwitchType $switchType

# Configure congestion control on the switch
$switch = Get-VMSwitch -Name $switchName
Set-NetQosTrafficClass -InterfaceAlias $switch.Name -Priority 1 -CongestionProvider ECN

# Enable the switch
Enable-VMSwitch -Name $switchName