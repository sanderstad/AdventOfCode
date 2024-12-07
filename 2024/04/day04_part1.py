ans = []

# This function searches for the given word
# in all 8 directions from the coordinate.
def search2D(grid, row, col, word):
    global ans
    m = len(grid)
    n = len(grid[0])

    # return false if the given coordinate
    # does not match with first index char.
    if grid[row][col] != word[0]:
        return False

    lenWord = len(word)

    # x and y are used to set the direction in which
    # word needs to be searched.
    x = [-1, -1, -1, 0, 0, 1, 1, 1]
    y = [-1, 0, 1, -1, 1, -1, 0, 1]

    # This loop will search in all the 8 directions
    # one by one. It will return true if one of the
    # directions contain the word.
    for dir in range(8):

        # Initialize starting point for current direction
        currX, currY = row + x[dir], col + y[dir]
        k = 1

        while k < lenWord:

            # break if out of bounds
            if currX >= m or currX < 0 or currY >= n or currY < 0:
                break

            # break if characters dont match
            if grid[currX][currY] != word[k]:
                break

            # Moving in particular direction
            currX += x[dir]
            currY += y[dir]
            k += 1

        # If all character matched, then value of must
        # be equal to length of word
        if k == lenWord:
            ans.append((row, col))


grid = open("input.txt").read().splitlines()
word = "XMAS"
m = len(grid)
n = len(grid[0])
for i in range(m):
    for j in range(n):
        search2D(grid, i, j, word)
#print(ans)
print(len(ans))