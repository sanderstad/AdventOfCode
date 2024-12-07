import re
import itertools


def get_lines(test=False):
    with open(("test" if test else "input") + ".txt") as file:
        for ln in file:
            yield ln.strip()


def parse_lines(lines):
    return prepare_rules(lines), prepare_updates(lines)


def prepare_rules(lines):
    return set(
        map(
            lambda pair: (int(pair[0]), int(pair[1])),
            re.findall(r"(\d+)\|(\d+)", ",".join(lines)),
        )
    )


def prepare_updates(lines):
    return list(
        map(
            lambda line: list(map(lambda n: int(n), line)),
            itertools.takewhile(
                lambda l: len(l) > 1, [l.split(",") for l in reversed(lines)]
            ),
        )
    )


def is_invalid_order(combination, rules):
    return tuple(reversed(combination)) in rules


def is_aligned_to_rules(update, rules):
    for combination in itertools.combinations(update, 2):
        if is_invalid_order(combination, rules):
            return False
    return True


def flip_value_positions(values, update):
    new_update = update.copy()
    new_update[update.index(values[0])] = values[1]
    new_update[update.index(values[1])] = values[0]
    return new_update


def flip_one_out_of_order_value(update, rules):
    for combination in itertools.combinations(update, 2):
        if is_invalid_order(combination, rules):
            return flip_value_positions(combination, update)
    raise Exception("No value to flip")


def align_to_rules(update, rules):
    return (
        update
        if is_aligned_to_rules(update, rules)
        else align_to_rules(flip_one_out_of_order_value(update, rules), rules)
    )


def middle_numbers(updates):
    return [update[len(update) // 2] for update in updates]


def solution_1(rules, updates):
    return sum(
        middle_numbers(
            [update for update in updates if is_aligned_to_rules(update, rules)]
        )
    )


def solution_2(rules, updates):
    return sum(
        middle_numbers(
            [
                align_to_rules(update, rules)
                for update in updates
                if not is_aligned_to_rules(update, rules)
            ]
        )
    )


def run():
    (rules, updates) = parse_lines(list(get_lines()))
    print("1:", solution_1(rules, updates))
    print("2:", solution_2(rules, updates))


run()