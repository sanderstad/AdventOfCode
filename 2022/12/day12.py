import networkx as nx
import numpy as np

from typing import Tuple

POINT_TYP = Tuple[int, int]


def sign(x):
    return -1 if x < 0 else (1 if x > 0 else 0)


def tuple_add(t1: POINT_TYP, t2: POINT_TYP):
    return (t1[0] + t2[0], t1[1] + t2[1])

with open('input.txt') as f:
    height_map = np.array([[ord(x) for x in line.strip()] for line in f.readlines()]).astype(np.byte)

start = tuple(np.argwhere(height_map == ord('S'))[0])
end = tuple(np.argwhere(height_map == ord('E'))[0])
# replace start and end
height_map[start] = ord('a')
height_map[end] = ord('z')
all_elements = {tuple(x) for x in np.transpose(height_map.nonzero())}
all_directions = [(0, 1), (0, -1), (1, 0), (-1, 0)]

G = nx.DiGraph()

for e in all_elements:
    current_height = height_map[e]
    for d in all_directions:
        test_location = tuple_add(e, d)
        if test_location in all_elements and height_map[test_location] - current_height <= 1:
            G.add_edge(e, test_location)

r1 = nx.shortest_path_length(G, start, end)
print(r1)

# part2
all_low_elements = [tuple(x) for x in np.argwhere(height_map == ord('a'))]
length, _ = nx.multi_source_dijkstra(G, all_low_elements, end)
print(length)