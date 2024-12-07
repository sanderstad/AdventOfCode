# Get the rules
#$rules = Get-Content -Path .\input_rules.txt
$rules = Get-Content -Path .\input_rules.txt

# Get the updates
#$updates = Get-Content -Path .\input_updates.txt
$updates = Get-Content -Path .\input_updates.txt


function Get-UpdatesSets([string[]]$Updates) {
    $updatesSets = @()

    # Loop through the updates
    foreach ($update in $Updates) {
        # Split the update into an array
        $updateArray = $update -split ','

        # Create a list of updates
        $updateList = @()

        # Loop through the update array
        for ($i = 0; $i -lt $updateArray.Count; $i++) {
            if ($i -eq $updateArray.Count - 1) {
                break
            }

            $updateList += "$($updateArray[$i])|$($updateArray[$i+1])"
        }

        # Create an object with the update and the update list
        $object = [PSCustomObject]@{
            Update     = $update
            UpdateList = $updateList
            Valid      = $null
        }

        # Add the object to the updates sets
        $updatesSets += $object

    }

    # Return the updates sets
    return $updatesSets
}

function Test-UpdateSets([PSCustomObject[]]$UpdateSets, [string[]]$Rules) {
    # Loop through the update sets
    foreach ($updateSet in $UpdateSets) {

        $updateSet.Valid = $true
        foreach ($item in $updateSet.UpdateList) {
            if ($item -in $Rules) {
                $updateSet.Valid = $true
            }
            else {
                $updateSet.Valid = $false
                break
            }
        }
    }

    # Return the update sets
    return $UpdateSets
}

function Get-MiddlePage([string]$Update) {
    $pages = $Update -split ','
    $middleIndex = [math]::Floor($pages.Count / 2)
    return [int]$pages[$middleIndex]
}

$updateSets = Get-UpdatesSets -updates $updates

$updateSets = Test-UpdateSets -UpdateSets $updateSets -Rules $rules

$updateSets | Format-Table

$middlePageSum = 0
foreach ($updateSet in $updateSets) {
    if ($updateSet.Valid) {
        $middlePage = Get-MiddlePage -Update $updateSet.Update
        $middlePage
        $middlePageSum += $middlePage
    }
}

Write-Host "Middle Page Sum: $middlePageSum"
