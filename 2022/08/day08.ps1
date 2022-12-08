# Import the raw data
$treeLines = get-content .\input_sample.txt
#$lines = get-content .\input.txt

$rows = @{}
$columns = @{}

# Init the rows
for($r = 0; $r -lt $treeLines.Count; $r++)
{
    if($treeLines[$r] -match "\d+")
    {
        $rows.Add($r, @())
    }
}

# Init the columns
$treeLine = $treeLines[0] -split '' | Where-Object { $_ -match "\d+" }

for($c = 0; $c -lt $treeLine.Count; $c++)
{
    $columns.Add($c, $())
}

# Get the rows
for($r = 0; $r -lt $treeLines.Count; $r++)
{
    # Initialize the rows and columns
    [array]$rowTrees = $treeLines[$r] -split '' | Where-Object { $_ -match "\d+" }

    $rowTreesArray = @()


    for($c = 0; $c -lt $rowTrees.Count; $c++)
    {
        $columnTreesArray = @()

        # Create the tree
        $rtree = [PSCustomObject]@{
            Position = $c
            Height = $rowTrees[$c]
            Visiblity = $false
        }

        # Set the visibility
        if(($c -eq 0) -or ($c -eq $rowTrees.Count -1))
        {
            $rtree.visiblity = $true
        }

        # Add the tree
        $rowTreesArray += $rtree

        # Continue to columns
        $ctree = [PSCustomObject]@{
            Position = $c
            Height = $rowTrees[$c]
            Visiblity = $false
        }

        # Set the visibility
        if($c -eq 0 -or ($c -eq $treeLines.Count -1))
        {
            $ctree.visiblity = $true
        }

        $columnTreesArray += $ctree

        # Add the tree
        $columns[$c] += $columnTreesArray
    }

    $rows[$r] = $rowTreesArray
}

foreach($key in $rows.Keys)
{
    $row = $rows[$key]

    for($i = 0; $i -lt $row.Count; $i++)
    {
        $tree = $row[$i]
        $tree.Position
        $tree.Height
        $tree.Visiblity
    }
}



# for($i = 0; $i -lt $rows.Count; $i++)
# {
#     $row = $rows[$i]

#     for($j = 0; $j -lt $row.Count; $j++)
#     {
#         $tree = $row[$j]
#         $tree.Position
#         $tree.Height
#         $tree.Visiblity
#     }
# }

# "ROWS"
# $rows[0]
# "COLUMNS"
# $columns[0]







