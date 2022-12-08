$lines = get-content .\input_part1.txt

# Set up the value catalog
$valueCatalog = @()
$value = 1
97..122 | ForEach-Object {$valueCatalog += [PSCustomObject]@{Letter = [char]$_; Value = $value}; $value++}
$value = 27
65..90 | ForEach-Object {$valueCatalog += [PSCustomObject]@{Letter = [char]$_; Value = $value}; $value++}

$duplicateItems = @()

foreach($line in $lines)
{
    $line
    $sectionEnd = $line.length / 2

    $compartment1 = $line.Substring(0, $sectionEnd)
    $compartment2 = $line.Substring($sectionEnd)

    $listCompartment1 = $compartment1 -split "" | Select-Object -Unique
    $listCompartment2 = $compartment2 -split "" | Select-Object -Unique

    $listCompartment1.ForEach{
        if($_ -cin $listCompartment2 -and $_ -ne "")
        {
            $duplicateItems += $_
        }
    }
}

$totalScore = 0

foreach($item in $duplicateItems)
{
    $totalScore += $valueCatalog | Where-Object { $_.Letter -ceq $item } | Select-Object -ExpandProperty Value
}

$totalScore