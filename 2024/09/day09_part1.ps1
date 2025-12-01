# Probably the uglyest code I've ever written, but it works.
# I don't know if I should be proud or ashamed of it.
# I'm going to be ashamed of it.
# Shame on me.
# Oh my god this is such a mess, it's soooo slow, but it works.

function Compact-DiskMap {
    param (
        [string]$DiskMap
    )

    # Split the disk map into individual characters
    $blocks = $DiskMap -split ''
    # Remove any empty strings from the split
    $blocks = $blocks | Where-Object { $_ }

    # Create disk layout with block type determined by modulo
    [array]$diskLayout = for ($i = 0; $i -lt $blocks.Count; $i++) {
        $type = $null
        if ($i % 2 -eq 0) {
            $type = 'File'
            $value = $blocks[$i]
        }
        else {
            $type = 'FreeSpace'
            $value = '.'
        }
        [PSCustomObject]@{
            Id     = [math]::Floor($i / 2)
            Type   = $type
            Length = [int]$blocks[$i]
            Value  = $value
        }
    }

    # Create detailed disk layout
    [array]$detailedDiskLayout = for ($i = 0; $i -lt $diskLayout.Count; $i++) {
        for ($j = 0; $j -lt $diskLayout[$i].Length; $j++) {
            [PSCustomObject]@{
                Id    = $diskLayout[$i].Id
                Type  = $diskLayout[$i].Type
                Value = $diskLayout[$i].Value
            }
        }
    }

    # Compaction process
    $compactionComplete = $false

    $iterationCount = 0
    $totalFiles = ($diskLayout | Where-Object { $_.Type -eq 'File' }).Count
    $filesMoved = 0

    while (-not $compactionComplete) {
        # Calculate free space
        $freeSpaceBlocks = ($detailedDiskLayout | Where-Object { $_.Type -eq 'FreeSpace' }).Count

        # Update progress bar with intelligent status
        $percentComplete = [math]::Min(($filesMoved / $totalFiles) * 100, 100)
        $statusMessage = "Moving files: $filesMoved/$totalFiles | Free Space: $freeSpaceBlocks blocks"
        Write-Progress -Activity "Compacting Disk" -Status $statusMessage -PercentComplete $percentComplete

        $compactionComplete = $true

        # Find the rightmost file block
        $rightmostFileIndex = -1
        for ($i = $detailedDiskLayout.Count - 1; $i -ge 0; $i--) {
            if ($detailedDiskLayout[$i].Type -eq 'File') {
                $rightmostFileIndex = $i
                break
            }
        }

        # Find the leftmost free space
        $leftmostFreeIndex = -1
        for ($i = 0; $i -lt $detailedDiskLayout.Count; $i++) {
            if ($detailedDiskLayout[$i].Type -eq 'FreeSpace') {
                $leftmostFreeIndex = $i
                break
            }
        }

        # If we found a file and a free space, move the file
        if (($rightmostFileIndex -ne -1) -and ($leftmostFreeIndex -ne -1) -and ($leftmostFreeIndex -lt $rightmostFileIndex)) {
            # Move the rightmost file block to the leftmost free space
            $fileBlock = $detailedDiskLayout[$rightmostFileIndex]
            $detailedDiskLayout[$leftmostFreeIndex] = $fileBlock
            $detailedDiskLayout[$rightmostFileIndex] = [PSCustomObject]@{
                Id    = $fileBlock.Id
                Type  = 'FreeSpace'
                Value = '.'
            }

            $compactionComplete = $false
            $filesMoved++
        }

        $iterationCount++
    }

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