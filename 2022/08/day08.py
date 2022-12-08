from functools import reduce

map = []
with open("input.txt") as f:
    for line in f.readlines():
        map.append([int(i) for i in list(line[:-1])])

maxHor = len(map[0])
maxVert = len(map)

invisible = 0
scenicScores = []

# Loop through the rows
for i in range(1, len(map[0])-1):
    # Loop through the columns
    for j in range(1, len(map)-1):
        L = [map[i][l] for l in [x for x in range(j-1, 0, -1)] + [0]]   # Left
        R = [map[i][r] for r in range(j+1, maxHor)]                     # Right
        U = [map[u][j] for u in [x for x in range(i-1, 0, -1)] + [0]]   # Up
        D = [map[d][j] for d in range(i+1, maxVert)]                    # Down

        # check for invisible trees
        if len([1 for s in [max(L), max(R), max(U), max(D)] if s < map[i][j]]) == 0:
            invisible += 1

        # calculate scenic score
        scores = []

        # Loop through the maps for up, down, left, right
        for view in [L, R, U, D]:
            s = []
            for t in view:
                if map[i][j] > t:
                    s.append(1)
                else:
                    s.append(0)
            try:
                s = s.index(0)+1
            except:
                s = len(s)
            scores.append(s)
        scenicScores.append(reduce(lambda x, y: x*y, scores))

print(f"Part 1 = {(maxHor*maxVert) - invisible}")
print(f"Part 2 = {max(scenicScores)}")