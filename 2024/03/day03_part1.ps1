function Get-MulNumbers {
    param (
        [string]$InputText
    )
    $pattern = 'mul\((\d+),(\d+)\)'  # Regular expression to match 'mul(x,y)' and capture x and y

    # Find all matches and extract the numbers into objects
    $matched = [regex]::Matches($InputText, $pattern)
    $objects = foreach ($match in $matched) {
        [pscustomobject]@{
            Number1 = [int]$match.Groups[1].Value
            Number2 = [int]$match.Groups[2].Value
        }
    }

    # Return the list of objects
    return $objects
}

# Example usage
$text = Get-Content -Path "input.txt" -Raw
$result = Get-MulNumbers -InputText $text

Write-Output "Extracted objects with numbers from mul(x,y):"

if ($result.Count -eq 0) {
    Write-Output "No objects with numbers extracted from mul(x,y) found."
    return
}

$total = 0

foreach ($object in $result) {
    Write-Output "Number1: $($object.Number1), Number2: $($object.Number2)"
    $total += $object.Number1 * $object.Number2
}

Write-Host "Total: $total"


