# Get the rules
#$rules = Get-Content -Path .\input_rules.txt
$rules = Get-Content -Path .\input_example_rules.txt

# Get the updates
#$updates = Get-Content -Path .\input_updates.txt
$updates = Get-Content -Path .\input_example_updates.txt


function Get-UpdatesSets([string[]]$Updates) {
    $updatesSets = @()

    # Loop through the updates
    foreach ($update in $Updates) {
        # Split the update into an array
        $updateArray = $update -split ','

        # Create a list of updates
        $updateList = @()

        # Possible correct values
        $possibleCorrectValues = @()

        # Loop through the update array
        for ($i = 0; $i -lt $updateArray.Count; $i++) {
            if ($i -eq $updateArray.Count - 1) {
                break
            }

            $updateList += "$($updateArray[$i])|$($updateArray[$i+1])"

            $possibleCorrectValues += "$($updateArray[$i+1])|$($updateArray[$i])"
        }

        # Create an object with the update and the update list
        $object = [PSCustomObject]@{
            Update                = $update
            UpdateList            = $updateList
            PossibleCorrectValues = $possibleCorrectValues
            InvalidPosition       = @()
            Valid                 = $null
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
        for ($i = 0; $i -lt $updateSet.UpdateList.Count; $i++) {
            if ($updateSet.UpdateList[$i] -in $Rules) {
                $updateSet.Valid = $true
            }
            else {
                $updateSet.Valid = $false
                $updateSet.InvalidPosition += $i
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

function Invoke-UpdateSetRepair([PSCustomObject[]]$UpdateSets, [string[]]$Rules) {
    foreach ($updateSet in $UpdateSets) {

        $updateSet | Add-Member -MemberType NoteProperty -Name CorrectedList -Value $null
        $updateSet | Add-Member -MemberType NoteProperty -Name CorrectedString -Value $null

        if ($updateSet.InvalidPosition.Count -ge 1) {
            $updateSet.CorrectedList = $updateSet.UpdateList

            foreach ($invalidPosition in $updateSet.InvalidPosition) {
                if ($updateSet.PossibleCorrectValues[$invalidPosition] -in $Rules) {
                    $updateSet.CorrectedList[$invalidPosition] = $updateSet.PossibleCorrectValues[$invalidPosition]
                }
            }

            $originalString = $updateSet.Update


        }

        # if ($updateSet.Valid) {
        #     $middlePage = Get-MiddlePage -Update $updateSet.Update
        #     $middlePage
        #     $middlePageSum += $middlePage
        # }
    }

    return $UpdateSets
}

$updateSets = Get-UpdatesSets -updates $updates

$updateSetsTested = Test-UpdateSets -UpdateSets $updateSets -Rules $rules

$updateSetsTested | Format-Table

""

$invalidUpdateSets = $updateSetsTested | Where-Object { $_.Valid -eq $false }

$updateSetsCorrected = Invoke-UpdateSetRepair -UpdateSets $invalidUpdateSets -Rules $rules

$updateSetsCorrected | Format-Table

$middlePageSum = 0
foreach ($updateSet in $updateSetsCorrected) {
    if ($updateSet.Valid) {
        $middlePage = Get-MiddlePage -Update $updateSet.Update
        $middlePage
        $middlePageSum += $middlePage
    }
}

Write-Host "Middle Page Sum: $middlePageSum"
