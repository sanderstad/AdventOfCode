# Get the content
$content = Get-Content -Path "$PSScriptRoot\input_part1.txt"
#$content = Get-Content -Path "$PSScriptRoot\input_example_part1.txt"

# Make the lists
$list1 = @()
$list2 = @()

$distance = 0

# Loop through the content
foreach ($line in $content) {
    # Split the line into two values
    $values = $line -split '   '

    # Store the values in the lists
    $list1 += [int]$values[0]
    $list2 += [int]$values[1]
}

# Now sort the lists
$listSorted1 = $list1 | Sort-Object
$listSorted2 = $list2 | Sort-Object

$listSorted1.Length

for ($i = 0; $i -lt $listSorted1.Length; $i++) {
    # Calculate the distance between the two values
    $currentDistance = [math]::Abs($listSorted1[$i] - $listSorted2[$i])

    # Add the distance to the total distance
    $distance += $currentDistance
    Write-Host "Distance between $($listSorted1[$i]) and $($listSorted2[$i]) is $distance"
}

Write-Host "The distance is $distance"