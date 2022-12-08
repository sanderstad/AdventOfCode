f = open('input.txt', 'r')
# then to store
lines = f.readlines()


def inclusive_range(a, b):
    return range(a, b + 1) if b > a else range(a, b - 1, -1)


def solve(input):
    lines = input.strip().split('\n')
    world = defaultdict(int)
    for line in lines:
        x0, y0, x1, y1 = [int(n) for n in line.replace(' -> ', ',').split(',')]
        if x0 == x1:
            for y in inclusive_range(y0, y1):
                world[(x0, y)] += 1
        elif y0 == y1:
            for x in inclusive_range(x0, x1):
                world[(x, y0)] += 1
        else:  # diagonal
            for x, y in zip(inclusive_range(x0, x1), inclusive_range(y0, y1)):
                world[(x, y)] += 1

    return sum(line_count > 1 for line_count in world.values())
