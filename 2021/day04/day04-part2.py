import numpy as np
import math


class BingoBoard:
    def __init__(self, string):
        nbs = [int(x) for x in string.split()]
        self.numbers = set(nbs)
        size = int(math.sqrt(len(nbs)))
        self.matrix = np.array(nbs, dtype=np.int16).reshape((size, size))

    def mark_nb(self, nb: int):
        if nb in self.numbers:
            found = np.where(self.matrix == nb)
            y, x = found[0][0], found[1][0]
            self.matrix[y][x] = -1

    def is_solved(self) -> bool:
        for i in range(self.matrix.shape[0]):
            # row i contains only marked numbers
            if np.all(self.matrix[i] == self.matrix[i][0]):
                return True
            # column i contains only marked nbs
            if np.all(self.matrix[:, i] == self.matrix[:, i][0]):
                return True
        return False

    def get_score(self):
        return sum([x[1] for x in np.ndenumerate(self.matrix) if x[1] != -1])


def part2(bingoBingoBoards: list[BingoBoard]):
    for x in nbs_todraw:
        for b in bingoBingoBoards:
            b.mark_nb(x)
        if len(bingoBingoBoards) >= 2:
            bingoBingoBoards = [
                b for b in bingoBingoBoards if not b.is_solved()]
        elif bingoBingoBoards[0].is_solved():
            return bingoBingoBoards[0].get_score() * x


lines = open('input.txt').read().split('\n\n')
nbs_todraw = [int(x) for x in lines.pop(0).split(',')]
BingoBoards = [BingoBoard(b) for b in lines]

print(f'Part2: {part2(BingoBoards)}')
