function Get-Antinodes {
    param($r1, $c1, $r2, $c2)

    $r = 2 * $r2 - $r1
    $c = 2 * $c2 - $c1
    if ($r -ge 0 -and $r -lt $script:HEIGHT -and $c -ge 0 -and $c -lt $script:WIDTH) {
        return @{r = $r; c = $c }
    }

    $r = 2 * $r1 - $r2
    $c = 2 * $c1 - $c2
    if ($r -ge 0 -and $r -lt $script:HEIGHT -and $c -ge 0 -and $c -lt $script:WIDTH) {
        return @{r = $r; c = $c }
    }
}

function Get-PointsOnLine {
    param($r1, $c1, $r2, $c2)

    $dr = $r2 - $r1
    $dc = $c2 - $c1

    for ($mult = 0; $true; $mult++) {
        $r = $r1 + $mult * $dr
        $c = $c1 + $mult * $dc

        if ($r -ge 0 -and $r -lt $script:HEIGHT -and $c -ge 0 -and $c -lt $script:WIDTH) {
            [PSCustomObject]@{r = $r; c = $c }
        }
        else {
            break
        }
    }
}

# Input handling
#$grid = Get-Content -Path .\input_example.txt
$grid = Get-Content -Path .\input.txt

$script:HEIGHT = $grid.Count
$script:WIDTH = $grid[0].Length

# Frequencies dictionary
$frequencies = @{}

# Find antenna locations
for ($r = 0; $r -lt $script:HEIGHT; $r++) {
    for ($c = 0; $c -lt $script:WIDTH; $c++) {
        $cell = $grid[$r][$c]
        if ($cell -ne '.') {
            if (-not $frequencies.ContainsKey($cell)) {
                $frequencies[$cell] = New-Object System.Collections.ArrayList
            }
            $null = $frequencies[$cell].Add(@{r = $r; c = $c })
        }
    }
}

$points1 = New-Object System.Collections.ArrayList
$points2 = New-Object System.Collections.ArrayList

# Process frequencies
foreach ($antennas in $frequencies.Values) {
    for ($i = 0; $i -lt $antennas.Count; $i++) {
        for ($j = $i + 1; $j -lt $antennas.Count; $j++) {
            $a = $antennas[$i]
            $b = $antennas[$j]

            # Find antinodes
            $antinode = Get-Antinodes -r1 $a.r -c1 $a.c -r2 $b.r -c2 $b.c
            if ($antinode) {
                $null = $points1.Add($antinode)
            }

            # Find points on lines
            $linePoints1 = Get-PointsOnLine -r1 $a.r -c1 $a.c -r2 $b.r -c2 $b.c
            $linePoints2 = Get-PointsOnLine -r1 $b.r -c1 $b.c -r2 $a.r -c2 $a.c

            foreach ($point in $linePoints1) {
                $null = $points2.Add($point)
            }
            foreach ($point in $linePoints2) {
                $null = $points2.Add($point)
            }
        }
    }
}

# Remove duplicates
$uniquePoints1 = ($points1 | Select-Object -Unique { "$($_.r),$($_.c)" }).Count
$uniquePoints2 = ($points2 | Select-Object -Unique { "$($_.r),$($_.c)" }).Count

Write-Host "Part 1: $uniquePoints1"
Write-Host "Part 2: $uniquePoints2"