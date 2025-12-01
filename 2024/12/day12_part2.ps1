function Find-GardenPlotRegions {
    param(
        [string[]]$Map
    )

    $height = $Map.Length
    $width = $Map[0].Length
    $regionMap = @{}
    $regions = [System.Collections.Generic.List[PSCustomObject]]::new()

    # First, find all connected regions
    for ($y = 0; $y -lt $height; $y++) {
        for ($x = 0; $x -lt $width; $x++) {
            if (-not $regionMap.ContainsKey("$x,$y")) {
                $region = Find-ConnectedRegion -Map $Map -StartX $x -StartY $y
                $regions.Add($region)

                # Mark all plots in this region
                foreach ($plot in $region.Plots) {
                    $regionMap[$plot] = $region
                }
            }
        }
    }

    return $regions
}

function Find-ConnectedRegion {
    param(
        [string[]]$Map,
        [int]$StartX,
        [int]$StartY
    )

    $height = $Map.Length
    $width = $Map[0].Length
    $plant = $Map[$StartY][$StartX]
    $visited = New-Object 'bool[,]' $height, $width
    $plots = New-Object System.Collections.Generic.HashSet[string]
    $queue = New-Object System.Collections.Queue

    $queue.Enqueue(@($StartX, $StartY))
    $visited[$StartY, $StartX] = $true

    $directions = @(
        @(0, 1), # Right
        @(0, -1), # Left
        @(1, 0), # Down
        @(-1, 0)  # Up
    )

    while ($queue.Count -gt 0) {
        $current = $queue.Dequeue()
        $x, $y = $current
        [void]$plots.Add("$x,$y")

        foreach ($dir in $directions) {
            $newX = $x + $dir[0]
            $newY = $y + $dir[1]

            if ($newX -ge 0 -and $newX -lt $width -and $newY -ge 0 -and $newY -lt $height) {
                if ($Map[$newY][$newX] -eq $plant -and -not $visited[$newY, $newX]) {
                    $queue.Enqueue(@($newX, $newY))
                    $visited[$newY, $newX] = $true
                }
            }
        }
    }

    $boundaryInfo = Calculate-RegionBoundary -Plots $plots -Map $Map

    [PSCustomObject]@{
        Plant = $plant
        Plots = $plots
        Area  = $plots.Count
        Sides = $boundaryInfo.NumberOfSides
        Price = $plots.Count * $boundaryInfo.NumberOfSides
    }
}

function Calculate-RegionBoundary {
    param(
        [System.Collections.Generic.HashSet[string]]$Plots,
        [string[]]$Map
    )

    $height = $Map.Length
    $width = $Map[0].Length

    # Create a quick lookup for plots
    $plotSet = New-Object 'System.Collections.Generic.HashSet[string]'
    foreach ($plot in $Plots) {
        [void]$plotSet.Add($plot)
    }

    # Directions for checking neighbors
    $directions = @(
        @{dx = 0; dy = 1; orientation = 'H' }, # Right
        @{dx = 0; dy = -1; orientation = 'H' }, # Left
        @{dx = 1; dy = 0; orientation = 'V' }, # Down
        @{dx = -1; dy = 0; orientation = 'V' }  # Up
    )

    $boundaryEdges = New-Object System.Collections.Generic.List[object]

    foreach ($plotCoord in $Plots) {
        $x, $y = $plotCoord -split ','
        $x = [int]$x
        $y = [int]$y

        foreach ($dir in $directions) {
            $newX = $x + $dir.dx
            $newY = $y + $dir.dy

            $isBoundary = $false
            if ($newX -lt 0 -or $newX -ge $width -or $newY -lt 0 -or $newY -ge $height) {
                # Outside the map
                $isBoundary = $true
            }
            else {
                # Inside the map, check if it's different
                if (-not $plotSet.Contains("$newX,$newY")) {
                    $isBoundary = $true
                }
            }

            if ($isBoundary) {
                if ($dir.dx -eq 0 -and $dir.dy -eq 1) {
                    # Right boundary
                    $edge = @(
                        @($x + 1, $y),
                        @($x + 1, $y + 1)
                    )
                }
                elseif ($dir.dx -eq 0 -and $dir.dy -eq -1) {
                    # Left boundary
                    $edge = @(
                        @($x, $y),
                        @($x, $y + 1)
                    )
                }
                elseif ($dir.dx -eq 1 -and $dir.dy -eq 0) {
                    # Down boundary
                    $edge = @(
                        @($x, $y + 1),
                        @($x + 1, $y + 1)
                    )
                }
                else {
                    # Up boundary
                    $edge = @(
                        @($x, $y),
                        @($x + 1, $y)
                    )
                }

                # Normalize edge ordering
                $p1 = $edge[0]
                $p2 = $edge[1]
                if (($p2[1] -lt $p1[1]) -or (($p2[1] -eq $p1[1]) -and ($p2[0] -lt $p1[0]))) {
                    $temp = $p1
                    $p1 = $p2
                    $p2 = $temp
                }

                $boundaryEdges.Add(( $p1, $p2 ))
            }
        }
    }

    # Build adjacency
    $adjEdges = [System.Collections.Generic.Dictionary[string, System.Collections.Generic.List[object]]]::new()

    foreach ($e in $boundaryEdges) {
        $start = $e[0]
        $end = $e[1]

        $startKey = "$($start[0]),$($start[1])"
        if (-not $adjEdges.ContainsKey($startKey)) {
            $adjEdges[$startKey] = [System.Collections.Generic.List[object]]::new()
        }
        $adjEdges[$startKey].Add($e)

        $endKey = "$($end[0]),$($end[1])"
        if (-not $adjEdges.ContainsKey($endKey)) {
            $adjEdges[$endKey] = [System.Collections.Generic.List[object]]::new()
        }
        $adjEdges[$endKey].Add($e)
    }

    function Get-NextEdge($currentVertex, $prevEdge, $adjEdges) {
        $vKey = "$($currentVertex[0]),$($currentVertex[1])"
        $edgesAtVertex = $adjEdges[$vKey]
        foreach ($candidate in $edgesAtVertex) {
            if ($candidate -ne $prevEdge) {
                return $candidate
            }
        }
        return $null
    }

    $visitedEdges = New-Object 'System.Collections.Generic.HashSet[string]'
    $loops = New-Object System.Collections.Generic.List[System.Object]

    foreach ($edge in $boundaryEdges) {
        $edgeKey = "$($edge[0][0]),$($edge[0][1])-$($edge[1][0]),$($edge[1][1])"
        if (-not $visitedEdges.Contains($edgeKey)) {
            # Start a new loop
            $loop = New-Object System.Collections.Generic.List[object]
            $loop.Add($edge)
            [void]$visitedEdges.Add($edgeKey)

            $startVertex = $edge[0]
            $endVertex = $edge[1]

            $currentVertex = $endVertex
            $prevEdge = $edge

            while ($currentVertex -ne $startVertex) {
                $nextEdge = Get-NextEdge $currentVertex $prevEdge $adjEdges
                if ($null -eq $nextEdge) {
                    break
                }

                $nk = "$($nextEdge[0][0]),$($nextEdge[0][1])-$($nextEdge[1][0]),$($nextEdge[1][1])"
                $nk2 = "$($nextEdge[1][0]),$($nextEdge[1][1])-$($nextEdge[0][0]),$($nextEdge[0][1])"
                if (-not $visitedEdges.Contains($nk)) {
                    [void]$visitedEdges.Add($nk)
                }
                elseif (-not $visitedEdges.Contains($nk2)) {
                    [void]$visitedEdges.Add($nk2)
                }

                $loop.Add($nextEdge)

                # Update current vertex
                if (($nextEdge[0][0] -eq $currentVertex[0]) -and ($nextEdge[0][1] -eq $currentVertex[1])) {
                    $currentVertex = $nextEdge[1]
                }
                else {
                    $currentVertex = $nextEdge[0]
                }
                $prevEdge = $nextEdge
            }

            $loops.Add($loop)
        }
    }

    function Get-Direction($edge) {
        $p1 = $edge[0]
        $p2 = $edge[1]
        if ($p1[0] -eq $p2[0]) {
            return "V"
        }
        else {
            return "H"
        }
    }

    $totalSides = 0
    foreach ($loop in $loops) {
        if ($loop.Count -eq 0) { continue }

        $directions = $loop | ForEach-Object { Get-Direction $_ }

        # Count transitions in direction
        $sides = 1
        for ($i = 1; $i -lt $directions.Count; $i++) {
            if ($directions[$i] -ne $directions[$i - 1]) {
                $sides++
            }
        }
        # Check join between last and first
        if ($directions[0] -ne $directions[$directions.Count - 1]) {
            $sides++
        }

        $totalSides += $sides
    }

    [PSCustomObject]@{
        NumberOfSides = $totalSides
    }
}

# Read input from file
#$map = Get-Content -Path "input.txt"
$map = Get-Content -Path "input_example_part2.txt"

# Find regions and calculate total price with the new method
$regions = Find-GardenPlotRegions -Map $map
$totalPrice = ($regions | Measure-Object -Property Price -Sum).Sum

Write-Host "Regions Found: $($regions.Count)"
foreach ($region in $regions) {
    Write-Host ("Region: {0}, Area: {1}, Sides: {2}, Price: {3}" -f $region.Plant, $region.Area, $region.Sides, $region.Price)
}
Write-Host "Total Fencing Price: $totalPrice"
