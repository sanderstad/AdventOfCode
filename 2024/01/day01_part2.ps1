# Get the content
$content = Get-Content -Path "$PSScriptRoot\input_part1.txt"
#$content = Get-Content -Path "$PSScriptRoot\input_example_part1.txt"

# Make the lists
$list1 = @()
$list2 = @()

$similarityScore = 0

# Loop through the content
foreach ($line in $content) {
    # Split the line into two values
    $values = $line -split '   '

    # Store the values in the lists
    $list1 += [int]$values[0]
    $list2 += [int]$values[1]
}

# Group the list with the same numbers
$listGrouped = $list2 | Group-Object

# Loop through the sorted list
foreach ($item in $list1) {
    $group = $listGrouped | Where-Object { $_.Name -eq $item }

    if ($group) {
        $score = [int]$item * $group.Count
        $similarityScore += $score
    }
    else {
        Write-Host "The number $item is not in the list"
    }
}

Write-Host "The similarity score is $similarityScore"