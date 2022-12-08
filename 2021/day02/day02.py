# Part 1

print("Part 1")

horizontal = depth = 0

f = open('input.txt', 'r')
# then to store
lines = f.readlines()

for l in lines:
    direction = l.split(" ")[0]
    value = int(l.split(" ")[1])

    match direction:
        case 'forward':
            horizontal += value
        case 'up':
            depth -= value
        case 'down':
            depth += value


print('horizontal: \t' + str(horizontal))
print('depth:\t\t' + str(depth))

print("total:\t\t" + str(horizontal*depth))

# Part 2
print("Part 2")
horizontal = depth = aim = 0

for l in lines:
    direction = l.split(" ")[0]
    value = int(l.split(" ")[1])

    match direction:
        case 'forward':
            horizontal += value
            depth += (value*aim)
        case 'up':
            aim -= value
        case 'down':
            aim += value

print('horizontal: \t' + str(horizontal))
print('depth:\t\t' + str(depth))

print("total:\t\t" + str(horizontal*depth))

f.close()

