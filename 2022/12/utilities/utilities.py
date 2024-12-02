from typing import Tuple

POINT_TYP = Tuple[int, int]


def sign(x):
    return -1 if x < 0 else (1 if x > 0 else 0)


def tuple_add(t1: POINT_TYP, t2: POINT_TYP):
    return (t1[0] + t2[0], t1[1] + t2[1])