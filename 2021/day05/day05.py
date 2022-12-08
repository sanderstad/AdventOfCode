# Part 1

class OceanFloor:
    def __init__(self, sizex, sizey):
        self.sizex = sizex
        self.sizey = sizey
        self.oceanmap = [[0] * self.sizex for i in range(self.sizey)]

    def process_coordinates(self, coordrange):

        coords1 = coordrange[0].split(",")
        coords2 = coordrange[1].split(",")

        if(coords1[0] >= coords2[0]):
            xfrom = int(coords1[0])
            xend = int(coords2[0])
        else:
            xfrom = int(coords2[0])
            xend = int(coords1[0])

        if(coords1[1] >= coords2[1]):
            yfrom = int(coords1[1])
            yend = int(coords2[1])
        else:
            yfrom = int(coords2[1])
            yend = int(coords1[1])

        for x in range(xfrom, xend + 1):
            for y in range(yfrom, yend + 1):
                self.oceanmap[x][y] += 1

    def count_overlap(self):
        count = 0
        for y in range(self.sizey):
            for x in range(self.sizex):
                if self.oceanmap[x][y] >= 2:
                    count += 1
        return count

    def print_map(self):
        for y in range(self.sizey):
            for x in range(self.sizex):
                print(self.oceanmap[y][x], end="")
            print()


f = open('input.txt', 'r')
# then to store
lines = f.readlines()

arr = []

xaxis = 0
yaxis = 0

for line in lines:
    line = line.strip()

    coord = line.split(' -> ')

    for i in range(len(coord)):
        c = coord[i].split(",")

        if int(c[0]) > xaxis:
            xaxis = int(c[0])

        if int(c[1]) > yaxis:
            yaxis = int(c[1])

    arr.append(coord)

if(xaxis > yaxis):
    max = xaxis
else:
    max = yaxis

mapping = OceanFloor(max, max)

for i in range(len(arr)):
    mapping.process_coordinates(arr[i])


print("Overlapping: " + str(mapping.count_overlap()))
