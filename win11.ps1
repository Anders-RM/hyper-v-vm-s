#run powershell script
#. "$PSScriptRoot/ExternalSwitch.ps1"

# Define variables
$vmName = "Windows11"
$vmMemory = 4096MB
$vmProcessorCount = 2
$vmDiskPath = "C:\VMs\Windows11\VHD\Windows11.vhdx"
$isoPath = "C:\ISOs\Windows11.iso"
$switchName = "ExternalSwitch"
$vhdPath = "C:\VMs\Windows11\VHD\Windows11.vhdx"
$vhdSize = 50GB

# Create an empty VHDX file
New-VHD -Path $vhdPath -SizeBytes $vhdSize -Dynamic

# Create a new virtual machine
New-VM -Name $vmName -MemoryStartupBytes $vmMemory -SwitchName $switchName -Path "C:\VMs"

# Set the number of virtual processors
Set-VMProcessor -VMName $vmName -Count $vmProcessorCount

# Add a virtual hard disk
Add-VMHardDiskDrive -VMName $vmName -Path $vmDiskPath

# Attach the ISO file
Add-VMDvdDrive -VMName $vmName -Path $isoPath

# Start the virtual machine
Start-VM -Name $vmName