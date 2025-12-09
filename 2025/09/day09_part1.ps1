# Day 9 Part 1 - Movie Theater - Find largest rectangle with red tiles as opposite corners

# Read input file
$inputFile = "input.txt"
$lines = Get-Content $inputFile

# Parse red tile coordinates
$redTiles = @()
foreach ($line in $lines) {
    $coords = $line.Split(',')
    $x = [long]$coords[0]
    $y = [long]$coords[1]
    $redTiles += [PSCustomObject]@{
        X = $x
        Y = $y
    }
}

Write-Host "Loaded $($redTiles.Count) red tiles"

# Find the largest rectangle
# For any two tiles to be opposite corners, they must differ in both X and Y
# Rectangle area = |x1 - x2| * |y1 - y2|
$maxArea = 0
$maxPair = $null

$totalPairs = ($redTiles.Count * ($redTiles.Count - 1)) / 2
$pairsChecked = 0
$lastProgress = 0

for ($i = 0; $i -lt $redTiles.Count; $i++) {
    for ($j = $i + 1; $j -lt $redTiles.Count; $j++) {
        $tile1 = $redTiles[$i]
        $tile2 = $redTiles[$j]

        # Calculate rectangle dimensions (inclusive of both corners)
        $width = [Math]::Abs($tile1.X - $tile2.X) + 1
        $height = [Math]::Abs($tile1.Y - $tile2.Y) + 1
        $area = $width * $height

        if ($area -gt $maxArea) {
            $maxArea = $area
            $maxPair = @($tile1, $tile2)
        }

        $pairsChecked++

        # Progress reporting
        $progress = [Math]::Floor(($pairsChecked / $totalPairs) * 100)
        if ($progress -ge $lastProgress + 10) {
            Write-Host "Progress: $progress% - Max area so far: $maxArea"
            $lastProgress = $progress
        }
    }
}

Write-Host ""
Write-Host "Largest rectangle area: $maxArea"
if ($maxPair) {
    Write-Host "Corner 1: ($($maxPair[0].X), $($maxPair[0].Y))"
    Write-Host "Corner 2: ($($maxPair[1].X), $($maxPair[1].Y))"
    $width = [Math]::Abs($maxPair[0].X - $maxPair[1].X) + 1
    $height = [Math]::Abs($maxPair[0].Y - $maxPair[1].Y) + 1
    Write-Host "Dimensions: $width x $height = $($width * $height)"
}
