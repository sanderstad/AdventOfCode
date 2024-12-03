# Get the content
#$content = Get-Content -Path "$PSScriptRoot\input_part1.txt"
$content = Get-Content -Path "$PSScriptRoot\input_example.txt"
#$content = Get-Content -Path "$PSScriptRoot\input_example2.txt"

function Test-LevelCheck {
    param (
        [int]$CurrentLevel,
        [int]$NextLevel
    )

    # Initialize the check
    $check = $true

    # Check the difference between the current and next values
    $difference = [math]::Abs($CurrentLevel - $NextLevel)

    # Check the difference
    if (($difference -gt 3) -or ($difference -eq 0)) {
        if ($difference -eq 0) {
            Write-Host " - Difference between $CurrentLevel and $NextLevel is 0"
        }
        else {
            Write-Host " - Difference too great between $CurrentLevel and $NextLevel is $difference"
        }

        $check = $false
    }
    else {
        Write-Host " - Difference between $CurrentLevel and $NextLevel is $difference"
    }

    return $check
}


function Get-ReportStatus {
    param (
        [string]$ReportLine
    )

    # Split the report line into levels
    $Levels = $ReportLine -split ' '

    # Initialize the status
    $status = $null

    # Get the type
    $type = $null

    if ([int]$Levels[0] -gt [int]$Levels[1]) {
        $type = 'Decreasing'
    }
    elseif ([int]$Levels[0] -lt [int]$Levels[1]) {
        $type = 'Increasing'
    }
    else {
        $type = 'Equal'
    }

    # Loop through the levels
    if ($type -eq 'Equal') {
        $status = $false
    }
    else {
        $previousValue = 0
        $previousStatus = $true

        for ($i = 0; $i -lt ($Levels.Length - 1 ); $i++) {
            # Get the current and next values
            $currentValue = [int]$Levels[$i]
            $nextValue = [int]$Levels[$i + 1]

            if ($type -eq 'Decreasing') {
                if ($currentValue -lt $nextValue) {
                    Write-Host " - Report should be decreasing, value $currentValue is less than $nextValue"
                    $status = $false
                }
            }
            elseif ($type -eq 'Increasing') {
                if ($currentValue -gt $nextValue) {
                    Write-Host " - Report should be increasing, value $currentValue is greater than $nextValue"
                    $status = $false
                }
            }

            # Check the difference between the current and next values
            $status = Test-LevelCheck -CurrentLevel $currentValue -NextLevel $nextValue

            if (($i -ne 0) -and ($status -eq $false) -and ($previousStatus -eq $true)) {
                Write-Host " - Applying The Problem Dampener"

                $status = Test-LevelCheck -CurrentLevel ([int]$Levels[$i - 1]) -NextLevel $nextValue

                if ($status -eq $true) {
                    Write-Host "   - The Problem Dampener worked"

                    $previousStatus = $status
                }
                else {
                    Write-Host "   - The Problem Dampener did NOT work!"
                    # Set the previous value
                    $previousValue = $currentValue
                    $previousStatus = $status

                    return $false
                }
            }

            # # Set the previous value
            # $previousValue = $currentValue
            # $previousStatus = $status
        }
    }

    return $status
}

$safeReports = 0

foreach ($line in $content) {

    Write-Host "Sending Report: $line"
    $reportStatus = Get-ReportStatus -ReportLine $line

    if ($reportStatus) {
        $safeReports++
        Write-Host " - The report is safe"
    }
    else {
        Write-Host " - The report is not safe"
    }
}

Write-Host "The number of safe reports is $safeReports"