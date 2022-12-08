$datastream = get-content .\input.txt
#$datastream = get-content .\input_sample2.txt -raw

$streamArray = $datastream -split "" 

$streamArray = $streamArray | where-object {$_ -ne ""}

$firstMarker = 0

# Part 1
for ($i = 0; $i -le $streamArray.Count; $i++) {
    if ($i -le ($datastream.Length - 3)) {
        $marker = $streamArray[$i..($i + 3)]
        
        $unique = $marker | select-object -Unique

        if($unique.Count -eq 4){
            $firstMarker = $i + 4
        }
    }  
}
"First marker part1: $firstMarker"

# Part 2
for ($i = $streamArray.Count; $i -ge 0; $i--) {
    if ($i -le ($datastream.Length - 13)) {
        $marker = $streamArray[($i + 13)..$i]
        
        $unique = $marker | select-object -Unique

        if($unique.Count -eq 14){
            $firstMarker = $i + 14
        }
    }  
}

"First marker part2: $firstMarker"