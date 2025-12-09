# Read junction box positions
$lines = Get-Content "input.txt"
$boxes = @()
foreach ($line in $lines) {
    $coords = $line -split ","
    $boxes += @([int]$coords[0], [int]$coords[1], [int]$coords[2])
}

Write-Host "Loaded $($boxes.Count) junction boxes"
Write-Host "Calculating distances..."

# Use a sorted list to efficiently get smallest distances
# Calculate distances on-the-fly and add to sorted list
$distances = New-Object 'System.Collections.Generic.SortedList[double, System.Collections.Generic.List[int[]]]'

for ($i = 0; $i -lt $boxes.Count; $i++) {
    if ($i % 100 -eq 0) { Write-Host "Processing box $i..." }
    
    for ($j = $i + 1; $j -lt $boxes.Count; $j++) {
        $dx = $boxes[$i][0] - $boxes[$j][0]
        $dy = $boxes[$i][1] - $boxes[$j][1]
        $dz = $boxes[$i][2] - $boxes[$j][2]
        $dist = $dx*$dx + $dy*$dy + $dz*$dz  # Use squared distance to avoid sqrt
        
        if (-not $distances.ContainsKey($dist)) {
            $distances[$dist] = New-Object 'System.Collections.Generic.List[int[]]'
        }
        $distances[$dist].Add(@($i, $j))
    }
}

Write-Host "Connecting junction boxes..."

# Union-Find data structure
$parent = @{}
$size = @{}
for ($i = 0; $i -lt $boxes.Count; $i++) {
    $parent[$i] = $i
    $size[$i] = 1
}

function Find-Root($x) {
    if ($parent[$x] -ne $x) {
        $parent[$x] = Find-Root $parent[$x]
    }
    return $parent[$x]
}

function Union($x, $y) {
    $rootX = Find-Root $x
    $rootY = Find-Root $y
    
    if ($rootX -eq $rootY) {
        return $false  # Already in same circuit
    }
    
    # Union by size
    if ($size[$rootX] -lt $size[$rootY]) {
        $parent[$rootX] = $rootY
        $size[$rootY] += $size[$rootX]
    } else {
        $parent[$rootY] = $rootX
        $size[$rootX] += $size[$rootY]
    }
    
    return $true
}

# Connect the first 1000 (or fewer if not enough) pairs
$connectionsToMake = 1000
$connectionsMade = 0

foreach ($distKey in $distances.Keys) {
    if ($connectionsMade -ge $connectionsToMake) {
        break
    }
    
    foreach ($pair in $distances[$distKey]) {
        if ($connectionsMade -ge $connectionsToMake) {
            break
        }
        
        if (Union $pair[0] $pair[1]) {
            $connectionsMade++
        }
    }
}

# Find all circuit sizes
$circuits = @{}
for ($i = 0; $i -lt $boxes.Count; $i++) {
    $root = Find-Root $i
    if (-not $circuits.ContainsKey($root)) {
        $circuits[$root] = $size[$root]
    }
}

# Get the three largest circuits
$topThree = $circuits.Values | Sort-Object -Descending | Select-Object -First 3

Write-Host "Top three circuit sizes: $($topThree -join ', ')"
$result = $topThree[0] * $topThree[1] * $topThree[2]
Write-Host "Product of three largest circuits: $result"
