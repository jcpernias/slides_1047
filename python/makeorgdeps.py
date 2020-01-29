#!/usr/bin/env python3

import argparse
import re


class Tracker:
    def __init__(self):
        self.checked = set()
        self.unchecked = set()

    def add(self, items):
        for i in items:
            self.unchecked.add(i)

    def pop(self):
        try:
            item = self.unchecked.pop()
            self.checked.add(item)
            return item
        except KeyError:
            return None

    def tracked(self):
        return self.checked


class Matcher:
    """A regexp and a handler in case of match"""

    def __init__(self, pat, handler):
        self.pat = re.compile(pat)
        self.handler = handler

    def process(self, text):
        m = self.pat.match(text)
        if m:
            return self.handler(m)
        return None


def always_none(m):
    """Always return None"""
    return None


def first_group(m):
    """Returns the first group of the match"""
    return m.group(1)


def process_line(line, matchers):
    """Process line with every Matcher until a match is found"""
    result = None
    for m in matchers:
        result = m.process(line)
        if result:
            break
    return result


org_matchers = (
    Matcher("^\s*#\s", always_none),
    Matcher("^\s*#[+]SETUPFILE:\s+(\S+)\s*$", first_group),
    Matcher("^\s*#[+]INCLUDE:\s+\"([^\":]+)", first_group)
)


def scan_org_file(org):
    deps = set()
    with open(org) as f:
        for l in f:
            d = process_line(l, org_matchers)
            if d is not None:
                deps.add(d)
    return deps


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("file", help="input file")
    parser.add_argument("-o", "--out", help="output file")
    parser.add_argument("-t", "--target", help="target file")
    # parser.add_argument("-d", "--dep", help="dependences file")
    args = parser.parse_args()
    input_file = args.file
    output_file = args.out
    target_file = args.target
    # dep_file = args.dep

    tracker = Tracker()
    f = input_file

    while f:
        new_deps = scan_org_file(f)
        tracker.add(new_deps)
        f = tracker.pop()

    deps = tracker.tracked()

    with open(output_file, 'w') as f:
        f.write('{}: {}\n\n'.format(output_file, input_file))
        f.write('{}: {}'.format(target_file, ' \\\n\t'.join(deps)))
        f.write('\n\n')
        # f.write(''.join([d + ':\n' for d in deps]))
