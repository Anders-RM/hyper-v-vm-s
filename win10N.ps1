# Run ExternalSwitch.ps1 script to configure the network switch
if (-not (Get-VMSwitch -Name "ExternalSwitch")) {
    # Create external switch
    & "$PSScriptRoot/ExternalSwitch.ps1"
}

# Define variables for the virtual machine
$vmName = "Windows 10"
$vmMemory = 4096MB
$vmProcessorCount = 2
$vmDiskPath = "C:\VMs\Windows10\VHD\Windows10.vhdx"
$isoPath = "C:\ISOs\Win10_Media_Creation_Tool.iso"
$switchName = "ExternalSwitch"
$vhdSize = 127GB

# Create an empty VHDX file for the virtual machine
New-VHD -Path $vmDiskPath -SizeBytes $vhdSize -Dynamic

# Create a new virtual machine with the specified settings
New-VM -Name $vmName -Generation 1 -MemoryStartupBytes $vmMemory -SwitchName $switchName -Path "C:\VMs"

# Set the number of virtual processors for the virtual machine
Set-VMProcessor -VMName $vmName -Count $vmProcessorCount

# Add a virtual hard disk to the virtual machine
Add-VMHardDiskDrive -VMName $vmName -Path $vmDiskPath

# Attach the ISO file to the virtual machine
Add-VMDvdDrive -VMName $vmName -Path $isoPath

Set-VM -Name $VMName -AutomaticCheckpointsEnabled $false

Set-VMFirmware -VMName $VMName -FirstBootDevice (Get-VMDvdDrive -VMName $VMName)

# Start the virtual machine
Start-VM -Name $vmName
