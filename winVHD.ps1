# Import necessary assemblies
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName Microsoft.VisualBasic

# Run ExternalSwitch.ps1 script to configure the network switch
if (-not (Get-VMSwitch -Name "ExternalSwitch")) {
    # Create external switch
    & "$PSScriptRoot/ExternalSwitch.ps1"
}

$hperVDefaultPath = (Get-VMHost).VirtualMachinePath

$vmName = [Microsoft.VisualBasic.Interaction]::InputBox("Enter the virtual machine name:", "Virtual Machine Name", "")

# Define variables for the virtual machine
$vmMemory = 4096MB
$vmProcessorCount = 2
$vmDiskPath = "$hperVDefaultPath\$vmName\VHD\"

# Prompt the user to select the .vhdx file using Windows UI
$openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
$openFileDialog.Filter = "VHDX Files (*.vhdx)|*.vhdx"
$openFileDialog.Title = "Select .vhdx File"
$dialogResult = $openFileDialog.ShowDialog()

if ($dialogResult -eq [System.Windows.Forms.DialogResult]::OK) {
    $vmDisk = $openFileDialog.FileName
    $vmDiskName = [System.IO.Path]::GetFileName($vmDisk)
    $vmDiskDestination = Join-Path -Path $vmDiskPath -ChildPath $vmDiskName

    $switchName = "ExternalSwitch"

    if (-not (Test-Path $vmDiskPath)) {
        New-Item $vmDiskPath -ItemType Directory -Force
    }

    Copy-Item -Path $vmDisk -Destination $vmDiskDestination

    # Create a new virtual machine with the specified settings
    New-VM -Name $vmName -Generation 2 -MemoryStartupBytes $vmMemory -SwitchName $switchName -Path $hperVDefaultPath

    # Set the number of virtual processors for the virtual machine
    Set-VMProcessor -VMName $vmName -Count $vmProcessorCount

    # Add a virtual hard disk to the virtual machine
    Add-VMHardDiskDrive -VMName $vmName -Path $vmDiskDestination

    # Set a new local key protector for the virtual machine
    Set-VMKeyProtector -VMName $VMName -NewLocalKeyProtector

    # Enable the TPM for the virtual machine
    Enable-VMTPM -VMName $VMName

    Set-VM -Name $VMName -AutomaticCheckpointsEnabled $false

    Set-VMFirmware -VMName $VMName -FirstBootDevice (Get-VMHardDiskDrive -VMName $VMName)

    # Start the virtual machine
    Start-VM -Name $vmName
}