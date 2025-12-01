function Find-GardenPlotRegions {
    param(
        [string[]]$Map
    )

    $height = $Map.Length
    $width = $Map[0].Length
    $regionMap = @{}
    $regions = @()

    # First, find all connected regions
    for ($y = 0; $y -lt $height; $y++) {
        for ($x = 0; $x -lt $width; $x++) {
            $plant = $Map[$y][$x]
            if (-not $regionMap.ContainsKey("$x,$y")) {
                $region = Find-ConnectedRegion -Map $Map -StartX $x -StartY $y
                $regions += $region

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
        @(-1, 0)   # Up
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

    return @{
        Plant     = $plant
        Plots     = $plots
        Area      = $plots.Count
        Perimeter = $boundaryInfo.PerimeterLength
        Price     = $plots.Count * $boundaryInfo.PerimeterLength
    }
}

function Calculate-RegionBoundary {
    param(
        [System.Collections.Generic.HashSet[string]]$Plots,
        [string[]]$Map
    )

    $height = $Map.Length
    $width = $Map[0].Length
    $perimeterSegments = 0

    # Convert plots to easier lookup
    $plotSet = New-Object 'System.Collections.Generic.HashSet[string]'
    foreach ($plot in $Plots) {
        [void]$plotSet.Add($plot)
    }

    # Directions to check around each plot
    $directions = @(
        @(0, 1, "-"), # Right
        @(0, -1, "-"), # Left
        @(1, 0, "|"), # Down
        @(-1, 0, "|")   # Up
    )

    foreach ($plotCoord in $Plots) {
        $x, $y = $plotCoord -split ','
        $x = [int]$x
        $y = [int]$y

        foreach ($dir in $directions) {
            $newX = $x + $dir[0]
            $newY = $y + $dir[1]
            $segmentType = $dir[2]

            # Check if this side is on the boundary
            if (-not $plotSet.Contains("$newX,$newY")) {
                # Check if it's map boundary or different plant type
                $isBoundary = $false
                if ($newX -lt 0 -or $newX -ge $width -or $newY -lt 0 -or $newY -ge $height) {
                    $isBoundary = $true
                }
                elseif ($newX -ge 0 -and $newX -lt $width -and $newY -ge 0 -and $newY -lt $height) {
                    if ($Map[$newY][$newX] -ne $Map[$y][$x]) {
                        $isBoundary = $true
                    }
                }

                if ($isBoundary) {
                    $perimeterSegments++
                }
            }
        }
    }

    return @{
        PerimeterLength = $perimeterSegments
    }
}

function Draw-RegionMap {
    param(
        [string[]]$Map,
        [array]$Regions
    )

    $height = $Map.Length
    $width = $Map[0].Length
    $visualMap = New-Object 'string[,]' ($height * 2 + 1), ($width * 2 + 1)

    # Initialize map with spaces
    for ($y = 0; $y -lt ($height * 2 + 1); $y++) {
        for ($x = 0; $x -lt ($width * 2 + 1); $x++) {
            $visualMap[$y, $x] = ' '
        }
    }

    # Draw grid lines
    for ($y = 0; $y -le $height; $y++) {
        for ($x = 0; $x -le $width; $x++) {
            $visualMap[($y * 2), ($x * 2)] = '+'
        }
    }

    # Draw horizontal and vertical lines between grid points
    for ($y = 0; $y -lt $height; $y++) {
        for ($x = 0; $x -lt $width; $x++) {
            $visualMap[($y * 2), ($x * 2 + 1)] = '-'
            $visualMap[($y * 2 + 1), ($x * 2)] = '|'
        }
    }

    # Color in the regions
    foreach ($region in $Regions) {
        foreach ($plot in $region.Plots) {
            $x, $y = $plot -split ','
            $x = [int]$x
            $y = [int]$y
            $visualMap[($y * 2 + 1), ($x * 2 + 1)] = $region.Plant
        }

        # Remove boundary lines within the region
        foreach ($plot in $region.Plots) {
            $x, $y = $plot -split ','
            $x = [int]$x
            $y = [int]$y

            foreach ($boundary in $region.Boundaries.GetEnumerator()) {
                $bx1, $by1, $bx2, $by2 = $boundary.Key -split ','
                $bx1 = [int]$bx1
                $by1 = [int]$by1
                $bx2 = [int]$bx2
                $by2 = [int]$by2

                if (($bx1 -eq $x -and $by1 -eq $y) -or ($bx2 -eq $x -and $by2 -eq $y)) {
                    $midX = ($bx1 + $bx2) / 2
                    $midY = ($by1 + $by2) / 2

                    if ($boundary.Value -eq '-') {
                        $visualMap[($y * 2 + 1), ($midX * 2 + 1)] = '-'
                    }
                    else {
                        $visualMap[($midY * 2 + 1), ($x * 2 + 1)] = '|'
                    }
                }
            }
        }
    }

    # Draw the map
    for ($y = 0; $y -lt ($height * 2 + 1); $y++) {
        $rowString = ""
        for ($x = 0; $x -lt ($width * 2 + 1); $x++) {
            $rowString += $visualMap[$y, $x]
        }
        Write-Host $rowString
    }
}

# Read input from file
$map = Get-Content -Path "input.txt"
#$map = Get-Content -Path "input_example.txt"

# Find regions and calculate total price
$regions = Find-GardenPlotRegions -Map $map
$totalPrice = ($regions | Measure-Object -Property Price -Sum).Sum

Write-Host "Regions Found: $($regions.Count)"
foreach ($region in $regions) {
    Write-Host ("Region: {0}, Area: {1}, Perimeter: {2}, Price: {3}" -f $region.Plant, $region.Area, $region.Perimeter, $region.Price)
}
Write-Host "Total Fencing Price: $totalPrice"

# Draw the map with regions and fences
# Write-Host "`nRegion Map with Fences:"
# Draw-RegionMap -Map $map -Regions $regions