function Find-ObstructionPositions {
    param (
        [string[]]$Map
    )

    # Reuse the existing map grid and direction logic from Get-GuardPatrolMap
    $mapGrid = @{}
    for ($y = 0; $y -lt $Map.Length; $y++) {
        for ($x = 0; $x -lt $Map[$y].Length; $x++) {
            $mapGrid["$x,$y"] = $Map[$y][$x]
        }
    }

    $directions = @{
        0 = @{x = 0; y = -1 }  # Up
        1 = @{x = 1; y = 0 }   # Right
        2 = @{x = 0; y = 1 }   # Down
        3 = @{x = -1; y = 0 }  # Left
    }

    $directionMap = @{
        '^' = 0  # Up
        '>' = 1  # Right
        'v' = 2  # Down
        '<' = 3  # Left
    }

    # Find starting position and direction
    $startKey = $mapGrid.GetEnumerator() | Where-Object { $_.Value -in $directionMap.Keys } | Sort-Object { $_.Name }
    $startPos = $startKey.Name
    $startDir = $directionMap["$($startKey.Value)"]

    $startX, $startY = $startPos -split ','

    # Function to simulate guard's path with an additional obstruction
    function Test-GuardLoop {
        param (
            [string]$ObstructionPos
        )

        $testGrid = $mapGrid.Clone()
        $testGrid[$ObstructionPos] = '#'

        $currX = [int]$startX
        $currY = [int]$startY
        $currDir = $startDir

        $visitedPositions = [System.Collections.Generic.HashSet[string]]::new()
        $null = $visitedPositions.Add("$currX,$currY")

        $iterationCount = 0
        $maxIterations = $testGrid.Count * 2  # Prevent infinite loops

        while ($iterationCount -lt $maxIterations) {
            $nextX = $currX + $directions[$currDir].x
            $nextY = $currY + $directions[$currDir].y
            $nextKey = "$nextX,$nextY"

            # Check if next position is in bounds and not an obstruction
            if (-not $testGrid.ContainsKey($nextKey) -or $testGrid[$nextKey] -eq '#') {
                # Obstacle or out of bounds, turn right
                $currDir = ($currDir + 1) % 4
            }
            else {
                # Move forward
                $currX = $nextX
                $currY = $nextY

                # Check for revisiting a position
                if ($visitedPositions.Contains("$currX,$currY")) {
                    return $true  # Loop detected
                }

                $null = $visitedPositions.Add("$currX,$currY")
            }

            $iterationCount++
        }

        return $false  # No loop detected
    }

    # Find possible obstruction positions
    $loopPositions = @()
    foreach ($pos in $mapGrid.Keys) {
        # Skip starting position and existing obstacles
        if ($pos -eq $startPos -or $mapGrid[$pos] -eq '#') {
            continue
        }

        # Verify if placing an obstacle at this position creates a loop
        if (Test-GuardLoop -ObstructionPos $pos) {
            $loopPositions += $pos
        }
    }

    return $loopPositions
}

# Read puzzle input
$puzzle = Get-Content -Path .\input_example.txt

# Find all loop-creating obstruction positions
$result = Find-ObstructionPositions -Map $puzzle
Write-Host "Number of possible obstruction positions: $($result.Count)"
Write-Host "Possible positions:`n$($result -join ', ')"