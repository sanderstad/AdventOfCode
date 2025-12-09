# Day 9 Part 2 - Final solution with proper edge validation

$inputFile = "input.txt"
$lines = Get-Content $inputFile

$redTiles = [System.Collections.ArrayList]::new()
foreach ($line in $lines) {
    $coords = $line.Split(',')
    $x = [long]$coords[0]
    $y = [long]$coords[1]
    [void]$redTiles.Add([PSCustomObject]@{
        X = $x
        Y = $y
    })
}

Write-Host "Loaded $($redTiles.Count) red tiles"

# Build green tiles
$greenTiles = @{}
for ($i = 0; $i -lt $redTiles.Count; $i++) {
    $current = $redTiles[$i]
    $next = $redTiles[($i + 1) % $redTiles.Count]

    if ($current.X -eq $next.X) {
        $minY = [Math]::Min($current.Y, $next.Y)
        $maxY = [Math]::Max($current.Y, $next.Y)
        for ($y = $minY; $y -le $maxY; $y++) {
            $greenTiles["$($current.X),$y"] = $true
        }
    } elseif ($current.Y -eq $next.Y) {
        $minX = [Math]::Min($current.X, $next.X)
        $maxX = [Math]::Max($current.X, $next.X)
        for ($x = $minX; $x -le $maxX; $x++) {
            $greenTiles["$x,$($current.Y)"] = $true
        }
    }
}

function Test-PointInPolygon {
    param($px, $py)
    $inside = $false
    for ($i = 0; $i -lt $redTiles.Count; $i++) {
        $j = ($i + 1) % $redTiles.Count
        $xi = $redTiles[$i].X
        $yi = $redTiles[$i].Y
        $xj = $redTiles[$j].X
        $yj = $redTiles[$j].Y
        $intersect = (($yi -gt $py) -ne ($yj -gt $py)) -and
                     ($px -lt ($xj - $xi) * ($py - $yi) / ($yj - $yi) + $xi)
        if ($intersect) { $inside = -not $inside }
    }
    return $inside
}

function Test-RectangleValid {
    param($minX, $maxX, $minY, $maxY)

    # Check edges with sampling every 100 units (for performance)
    $stepX = [Math]::Max(1, [Math]::Floor(($maxX - $minX) / 100))
    $stepY = [Math]::Max(1, [Math]::Floor(($maxY - $minY) / 100))

    # Check top and bottom edges
    for ($x = $minX; $x -le $maxX; $x += $stepX) {
        foreach ($y in @($minY, $maxY)) {
            $key = "$x,$y"
            if (-not ($greenTiles.ContainsKey($key) -or (Test-PointInPolygon -px $x -py $y))) {
                return $false
            }
        }
    }
    # Check last point on horizontal edges
    foreach ($y in @($minY, $maxY)) {
        $key = "$maxX,$y"
        if (-not ($greenTiles.ContainsKey($key) -or (Test-PointInPolygon -px $maxX -py $y))) {
            return $false
        }
    }

    # Check left and right edges
    for ($y = $minY; $y -le $maxY; $y += $stepY) {
        foreach ($x in @($minX, $maxX)) {
            $key = "$x,$y"
            if (-not ($greenTiles.ContainsKey($key) -or (Test-PointInPolygon -px $x -py $y))) {
                return $false
            }
        }
    }
    # Check last point on vertical edges
    foreach ($x in @($minX, $maxX)) {
        $key = "$x,$maxY"
        if (-not ($greenTiles.ContainsKey($key) -or (Test-PointInPolygon -px $x -py $maxY))) {
            return $false
        }
    }

    return $true
}

$maxArea = 0
$maxPair = $null
$maxGap = 50

Write-Host "Checking pairs within gap of $maxGap..."

for ($i = 0; $i -lt $redTiles.Count; $i++) {
    for ($offset = 2; $offset -le $maxGap; $offset++) {
        $j = ($i + $offset) % $redTiles.Count

        $tile1 = $redTiles[$i]
        $tile2 = $redTiles[$j]

        $minX = [Math]::Min($tile1.X, $tile2.X)
        $maxX = [Math]::Max($tile1.X, $tile2.X)
        $minY = [Math]::Min($tile1.Y, $tile2.Y)
        $maxY = [Math]::Max($tile1.Y, $tile2.Y)

        $width = $maxX - $minX + 1
        $height = $maxY - $minY + 1
        $area = $width * $height

        if ($area -gt $maxArea) {
            if (Test-RectangleValid -minX $minX -maxX $maxX -minY $minY -maxY $maxY) {
                $maxArea = $area
                $maxPair = @($i, $j, $offset)
                Write-Host "  New max: $maxArea at indices $i -> $j (gap $offset)"
            }
        }
    }

    if ($i % 50 -eq 0) {
        Write-Host "Progress: $([Math]::Floor($i*100/$redTiles.Count))%"
    }
}

Write-Host ""
Write-Host "Answer: $maxArea"
if ($maxPair) {
    Write-Host "Indices: $($maxPair[0]) -> $($maxPair[1]) (gap $($maxPair[2]))"
}
