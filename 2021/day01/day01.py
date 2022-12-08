# Part 1

f = open('measurements.txt', 'r')
# then to store
lines = f.readlines()

increaseCount = 0

for i in range(len(lines)):
    if(i > 0):
        if(int(lines[i]) > int(lines[i - 1])):
            increaseCount += 1

print(increaseCount)

# Part 2

prev = 0

increaseCount = 0

for l in range(len(lines)-2):
    current = int(lines[l]) + int(lines[l + 1]) + int(lines[l + 2])

    if(prev != 0 and (current > prev)):
        increaseCount += 1

    prev = current
print(increaseCount)

f.close()
