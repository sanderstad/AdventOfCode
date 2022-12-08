$lines = get-content .\input_part1.txt

# Set up the value catalog
$valueCatalog = @()
$value = 1
97..122 | ForEach-Object {$valueCatalog += [PSCustomObject]@{Letter = [char]$_; Value = $value}; $value++}
$value = 27
65..90 | ForEach-Object {$valueCatalog += [PSCustomObject]@{Letter = [char]$_; Value = $value}; $value++}

$recurringItems = @()

$counter = 0
$group = 0

$lineItems = @()

# Split up the groups
foreach($line in $lines)
{
    if($counter % 3 -eq 0)
    {
        $group++
    }

    $lineItems += [PSCustomObject]@{
        LineNumer = ($counter+1)
        Line = $line
        Group = $group
    }

    $counter++
}


#for($i = 1; $i -le $lineItems.Length; $i++)
for($i = 1; $i -le $group; $i++)
{

    $lines = $lineItems | Where-Object { $_.Group -eq $i } | Select-Object -ExpandProperty Line

    $lines

    $listLine1 = $lines[0] -split "" | Select-Object -Unique
    $listLine2 = $lines[1] -split "" | Select-Object -Unique
    $listLine3 = $lines[2] -split "" | Select-Object -Unique

    $listLine1.ForEach{
        if($_ -cin $listLine2 -and $_ -cin $listLine3 -and $_ -ne "")
        {
            $recurringItems += $_
        }
    }
}

$totalScore = 0

foreach($item in $recurringItems)
{
    $totalScore += $valueCatalog | Where-Object { $_.Letter -ceq $item } | Select-Object -ExpandProperty Value
}

$totalScore