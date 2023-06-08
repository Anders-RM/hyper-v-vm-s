#run powershell script
$PSScriptRoot/"ExternalSwitch.ps1"

# Define variables
$vmName = "Windows 11"
$vmMemory = 4096
$vmProcessorCount = 2
$vmDiskPath = "C:\VMs\Windows 11\Virtual Hard Disks\Windows 11.vhdx"
$isoPath = "C:\ISOs\Windows 11.iso"

# Create a new virtual machine
New-VM -Name $vmName -MemoryStartupBytes $vmMemory -SwitchName "Default" -Path "C:\VMs"

# Set the number of virtual processors
Set-VMProcessor -VMName $vmName -Count $vmProcessorCount

# Add a virtual hard disk
Add-VMHardDiskDrive -VMName $vmName -Path $vmDiskPath

# Attach the ISO file
Add-VMDvdDrive -VMName $vmName -Path $isoPath

# Start the virtual machine
Start-VM -Name $vmName