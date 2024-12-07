grid = open("input.txt").read().splitlines()
m = len(grid)
n = len(grid[0])
candidates = []
score = 0
# find all coords that contain letter "A"
# stay 1 character away from the boundary
for i in range(1,m-1):
    for j in range(1,n-1):
         if grid[i][j] == "A":
            candidates.append((i,j))
print(candidates)
for i,j in candidates:
        if (grid[i-1][j-1] == "S" and grid[i+1][j+1] == "M") or (grid[i-1][j-1] == "M" and grid[i+1][j+1] == "S"):
            if (grid[i+1][j-1] == "S" and grid[i-1][j+1] == "M") or (grid[i+1][j-1] == "M" and grid[i-1][j+1] == "S"):
                score+=1
print(score)