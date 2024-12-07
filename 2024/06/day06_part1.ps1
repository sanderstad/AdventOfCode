function Get-GuardPatrolMap {
    param (
        [string[]]$Map
    )

    # Create a hashtable to represent the map
    $mapGrid = @{}
    for ($y = 0; $y -lt $Map.Length; $y++) {
        for ($x = 0; $x -lt $Map[$y].Length; $x++) {
            $mapGrid["$x,$y"] = $Map[$y][$x]
        }
    }

    # Directions mapping: 0 = Up, 1 = Right, 2 = Down, 3 = Left
    $directions = @{
        0 = @{x = 0; y = -1 }  # Up
        1 = @{x = 1; y = 0 }   # Right
        2 = @{x = 0; y = 1 }   # Down
        3 = @{x = -1; y = 0 }  # Left
    }

    # Mapping starting characters to initial directions
    $directionMap = @{
        '^' = 0  # Up
        '>' = 1  # Right
        'v' = 2  # Down
        '<' = 3  # Left
    }

    # Find starting position and direction
    $startPos = $null
    $startDir = $null

    $startKey = $mapGrid.GetEnumerator() | Where-Object { $_.Value -in $directionMap.Keys } | Sort-Object { $_.Name }
    $startPos = $startKey.Name
    $startDir = $directionMap["$($startKey.Value)"]

    Write-Host "Found starting position: $startPos, direction: $startDir"

    # Split starting position into x and y
    $startX, $startY = $startPos -split ','

    # Initialize tracking variables
    $visited = [System.Collections.Generic.HashSet[string]]::new()
    $currX = [int]$startX
    $currY = [int]$startY
    $currDir = $startDir

    # Mark starting position
    $null = $visited.Add("$currX,$currY")
    $mapGrid["$currX,$currY"] = 'X'

    $minX = $maxX = $currX
    $minY = $maxY = $currY

    while ($true) {
        # Calculate next position
        $nextX = $currX + $directions[$currDir].x
        $nextY = $currY + $directions[$currDir].y
        $nextKey = "$nextX,$nextY"

        Write-Host "Next position: $nextKey"

        # Check if we've left the mapped area
        if (-not $mapGrid.ContainsKey("$nextKey")) {
            break
        }

        # Check if next position is in bounds and not an obstruction
        if (-not $mapGrid.ContainsKey($nextKey) -or $mapGrid[$nextKey] -eq '#') {
            # Obstacle or out of bounds, turn right
            Write-Host "Obstacle detected, turning right"
            $currDir = ($currDir + 1) % 4
        }
        else {
            # Move forward
            $currX = $nextX
            $currY = $nextY

            # Update map boundaries
            $minX = [Math]::Min($minX, $currX)
            $maxX = [Math]::Max($maxX, $currX)
            $minY = [Math]::Min($minY, $currY)
            $maxY = [Math]::Max($maxY, $currY)

            # Mark position if not already an obstacle
            if ($mapGrid["$currX,$currY"] -ne '#') {
                $mapGrid["$currX,$currY"] = 'X'
            }

            $null = $visited.Add("$currX,$currY")
        }


    }

    # Reconstruct the map for display
    $finalMap = @()
    for ($y = $minY; $y -le $maxY; $y++) {
        $row = ""
        for ($x = $minX; $x -le $maxX; $x++) {
            $key = "$x,$y"
            $row += if ($mapGrid.ContainsKey($key)) { $mapGrid[$key] } else { '.' }
        }
        $finalMap += $row
    }

    # Return an object with complete information
    return [PSCustomObject]@{
        PositionCount = $visited.Count
        VisitedMap    = $finalMap
        Coordinates   = ($visited | ForEach-Object {
                $coords = $_ -split ','
                [PSCustomObject]@{
                    X = [int]$coords[0]
                    Y = [int]$coords[1]
                }
            })
    }
}

# Uncomment and modify the example usage as needed

# $exampleMap = @"
# ....#.....
# .........#
# ..........
# ..#.......
# .......#..
# ..........
# .#..^.....
# ........#.
# #.........
# ......#...
# "@ -split "`n"

$puzzle = Get-Content -Path .\input.txt

$result = Get-GuardPatrolMap -Map $puzzle
Write-Host "`nPatrol Map:"
$result.VisitedMap | ForEach-Object { $_ }

Write-Host "Distinct positions visited: $($result.PositionCount)"