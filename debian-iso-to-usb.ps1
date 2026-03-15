$ErrorActionPreference='Stop'
# '\\.\PhysicalDrive1' -> this number '1' is taken from 'get-disk' psh command it shows 'Number' of USB disk
#$disks = get-disk
#throw 'assert 100% sure pahs are valid to not desploy C:\ disk! and comment this error'

#need to unmount USB drive so it will not show 'E:\' in my computer, use this command:
#mountvol E: /d

#need to execute diskpart:

@*
PS C:\my-files\temp-work> diskpart
Microsoft DiskPart version 10.0.26100.1150
Copyright (C) Microsoft Corporation.
On computer: DESKTOP-3F4E02I
DISKPART> select disk 1
Disk 1 is now the selected disk.
DISKPART> clean
DiskPart succeeded in cleaning the disk.
DISKPART>
*@

$IsoPath = 'C:\my-files\virtual-machines\debian-13.3.0-amd64-netinst.iso'
#$disk = "\\.\PhysicalDrive1"

$DiskNumber = 1

Write-Host "Debian ISO:" $IsoPath
Write-Host "Target disk:" $DiskNumber
Write-Host ""

$confirm = Read-Host "ALL DATA on disk $DiskNumber will be destroyed. Type YES to continue"
if ($confirm -ne "YES") {
    Write-Host "Aborted."
    exit
}

# Remove mounted partitions so Windows releases the device
Write-Host "Dismounting volumes..."
Get-Partition -DiskNumber $DiskNumber -ErrorAction SilentlyContinue | ForEach-Object {
    Remove-PartitionAccessPath -DiskNumber $DiskNumber -PartitionNumber $_.PartitionNumber -AccessPath $_.AccessPaths[0] -ErrorAction SilentlyContinue
}

$devicePath = "\\.\PhysicalDrive$DiskNumber"

Write-Host "Opening ISO..."
$isoStream = [System.IO.File]::OpenRead($IsoPath)

Write-Host "Opening disk device..."
$diskStream = New-Object System.IO.FileStream(
    $devicePath,
    [System.IO.FileMode]::Open,
    [System.IO.FileAccess]::ReadWrite
)

$bufferSize = 4MB
$buffer = New-Object byte[] $bufferSize

$total = $isoStream.Length
$written = 0

Write-Host "Writing ISO to USB..."

while (($read = $isoStream.Read($buffer,0,$buffer.Length)) -gt 0) {
    $diskStream.Write($buffer,0,$read)
    $written += $read

    $percent = [math]::Round(($written/$total)*100,2)
    Write-Progress -Activity "Writing ISO" -Status "$percent% Complete" -PercentComplete $percent
}

$diskStream.Flush()
$diskStream.Close()
$isoStream.Close()

Write-Host ""
Write-Host "Done. USB should now be bootable."