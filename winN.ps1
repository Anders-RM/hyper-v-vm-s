# Import necessary assemblies
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName Microsoft.VisualBasic

# Run ExternalSwitch.ps1 script to configure the network switch
if (-not (Get-VMSwitch -Name "ExternalSwitch")) {
    # Create external switch
    & "$PSScriptRoot/ExternalSwitch.ps1"
}

$hperVDefaultPath = (Get-VMHost).VirtualMachinePath

# Prompt the user for the vmName using the InputBox
$vmName = [Microsoft.VisualBasic.Interaction]::InputBox("Enter the virtual machine name:", "Virtual Machine Name", "")

# Define other variables for the virtual machine
$vmMemory = 4096MB
$vmProcessorCount = 2
$switchName = "ExternalSwitch"
$vhdSize = 127GB
$vmDiskPath = "$hperVDefaultPath\$vmName\VHD\$vmName.vhdx"

# Prompt the user for the ISO file location using the Windows UI
$openFileDialog = New-Object -TypeName System.Windows.Forms.OpenFileDialog
$openFileDialog.Title = "Select ISO File"
$openFileDialog.Filter = "ISO Files (*.iso)|*.iso"

$isoPath = if ($openFileDialog.ShowDialog() -eq 'OK') {
    $openFileDialog.FileName
} else {
    Write-Error "No file selected."
    return
}

# Create an empty VHDX file for the virtual machine
New-VHD -Path $vmDiskPath -SizeBytes $vhdSize -Dynamic

# Create a new virtual machine with the specified settings
New-VM -Name $vmName -Generation 2 -MemoryStartupBytes $vmMemory -SwitchName $switchName -Path $hperVDefaultPath

# Set the number of virtual processors for the virtual machine
Set-VMProcessor -VMName $vmName -Count $vmProcessorCount

# Add a virtual hard disk to the virtual machine
Add-VMHardDiskDrive -VMName $vmName -Path $vmDiskPath

# Attach the ISO file to the virtual machine
Add-VMDvdDrive -VMName $vmName -Path $isoPath

# Set a new local key protector for the virtual machine
Set-VMKeyProtector -VMName $VMName -NewLocalKeyProtector

# Enable the TPM for the virtual machine
Enable-VMTPM -VMName $VMName

Set-VM -Name $VMName -AutomaticCheckpointsEnabled $false

Set-VMFirmware -VMName $VMName -FirstBootDevice (Get-VMDvdDrive -VMName $VMName)

# Start the virtual machine
Start-VM -Name $vmName