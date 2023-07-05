# Run ExternalSwitch.ps1 script to configure the network switch
if (-not (Get-VMSwitch -Name "ExternalSwitch")) {
    # Create external switch
    & "$PSScriptRoot/ExternalSwitch.ps1"
}
$hperVDefaultPath  = (Get-VMHost).VirtualMachinePath
# Define variables for the virtual machine
$vmName = "Windows11"
$vmMemory = 4096MB
$vmProcessorCount = 2
$vmDiskPath = "$hperVDefaultPath\$vmName\VHD\Windows11.vhdx"
$switchName = "ExternalSwitch"

Copy-Item .\Windows11.vhdx $vmDiskPath

# Create a new virtual machine with the specified settings
New-VM -Name $vmName -Generation 2 -MemoryStartupBytes $vmMemory -SwitchName $switchName -Path "C:\VMs"

# Set the number of virtual processors for the virtual machine
Set-VMProcessor -VMName $vmName -Count $vmProcessorCount

# Add a virtual hard disk to the virtual machine
Add-VMHardDiskDrive -VMName $vmName -Path $vmDiskPath

# Set a new local key protector for the virtual machine
Set-VMKeyProtector -VMName $VMName -NewLocalKeyProtector

# Enable the TPM for the virtual machine
Enable-VMTPM -VMName $VMName

Set-VM -Name $VMName -AutomaticCheckpointsEnabled $false

Set-VMFirmware -VMName $VMName -FirstBootDevice (Get-VMHardDiskDrive -VMName $VMName)

# Start the virtual machine
Start-VM -Name $vmName



