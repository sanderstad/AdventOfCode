function Compact-DiskMap {
    param (
        [string]$DiskMap
    )

    # Split the disk map into individual characters
    $blocks = $DiskMap -split '' | Where-Object { $_ }

    # Create initial disk layout
    [array]$diskLayout = for ($i = 0; $i -lt $blocks.Count; $i++) {
        $type = if ($i % 2 -eq 0) { 'File' } else { 'FreeSpace' }
        [PSCustomObject]@{
            Id     = [math]::Floor($i / 2)
            Type   = $type
            Length = [int]$blocks[$i]
            Value  = if ($type -eq 'File') { $blocks[$i] } else { '.' }
        }
    }

    # Create detailed disk layout
    [array]$detailedDiskLayout = foreach ($block in $diskLayout) {
        1..$block.Length | ForEach-Object {
            [PSCustomObject]@{
                Id    = $block.Id
                Type  = $block.Type
                Value = $block.Value
            }
        }
    }

    # Track files for progress
    $totalFiles = ($diskLayout | Where-Object { $_.Type -eq 'File' }).Count
    $filesMoved = 0

    # Find and compact empty spaces
    $emptySpaces = @()
    for ($i = 0; $i -lt $detailedDiskLayout.Count; $i++) {
        if ($detailedDiskLayout[$i].Type -eq 'FreeSpace') {
            $emptySpaces += $i
        }
    }

    # Compact files into empty spaces
    $nextEmptyIndex = 0
    for ($i = 0; $i -lt $detailedDiskLayout.Count; $i++) {
        if ($detailedDiskLayout[$i].Type -eq 'File') {
            if ($nextEmptyIndex -lt $emptySpaces.Count -and $emptySpaces[$nextEmptyIndex] -lt $i) {
                # Move file to empty space
                $detailedDiskLayout[$emptySpaces[$nextEmptyIndex]] = $detailedDiskLayout[$i]
                $detailedDiskLayout[$i] = [PSCustomObject]@{
                    Id    = $detailedDiskLayout[$i].Id
                    Type  = 'FreeSpace'
                    Value = '.'
                }
                $nextEmptyIndex++
                $filesMoved++

                # Update progress bar
                $freeSpaceBlocks = ($detailedDiskLayout | Where-Object { $_.Type -eq 'FreeSpace' }).Count
                $percentComplete = [math]::Min(($filesMoved / $totalFiles) * 100, 100)
                $statusMessage = "Moving files: $filesMoved/$totalFiles | Free Space: $freeSpaceBlocks blocks"
                Write-Progress -Activity "Compacting Disk" -Status $statusMessage -PercentComplete $percentComplete
            }
        }
    }

    # Clear progress bar
    Write-Progress -Activity "Compacting Disk" -Completed

    # Calculate checksum
    $checksum = 0
    for ($i = 0; $i -lt $detailedDiskLayout.Count; $i++) {
        if ($detailedDiskLayout[$i].Type -eq 'File') {
            $checksum += $i * $detailedDiskLayout[$i].Id
        }
    }

    return $checksum
}

# Example usage
$diskMap = Get-Content -Path .\input.txt -Raw
#$diskMap = Get-Content -Path .\input_example.txt -Raw
$result = Compact-DiskMap -DiskMap $diskMap
Write-Host "Filesystem Checksum: $result"