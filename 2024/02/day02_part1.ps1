# Get the content
$content = Get-Content -Path "$PSScriptRoot\input_part1.txt"
#$content = Get-Content -Path "$PSScriptRoot\input_example.txt"

function Get-ReportStatus {
    param (
        [string]$ReportLine
    )

    # Split the report line into levels
    $Levels = $ReportLine -split ' '

    # Initialize the status
    $status = $true

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
        for ($i = 0; $i -lt ($Levels.Length - 1); $i++) {
            # Get the current and next values
            $currentValue = [int]$Levels[$i]
            $nextValue = [int]$Levels[$i + 1]

            if ($type -eq 'Decreasing') {
                if ($currentValue -lt $nextValue) {
                    Write-Host " - Report should be decreasing, value $currentValue is less than $nextValue"
                    $status = $false
                    break
                }
            }
            elseif ($type -eq 'Increasing') {
                if ($currentValue -gt $nextValue) {
                    Write-Host " - Report should be increasing, value $currentValue is greater than $nextValue"
                    $status = $false
                    break
                }
            }

            $difference = [math]::Abs($currentValue - $nextValue)

            if (($difference -gt 3) -or ($difference -eq 0)) {
                Write-Host " - Difference between $currentValue and $nextValue is $difference"
                $status = $false
                break
            }
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
}

Write-Host "The number of safe reports is $safeReports"