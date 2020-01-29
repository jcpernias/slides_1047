#!/usr/bin/env python3

import argparse
import re
import os
import os.path


class Matcher:
    """A regexp and a handler in case of match"""

    def __init__(self, pat, handler):
        self.pat = re.compile(pat, re.IGNORECASE)
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

def second_group(m):
    """Returns the first group of the match"""
    return m.group(2)

def process_line(line, matchers):
    """Process line with every Matcher until a match is found"""
    result = None
    for m in matchers:
        result = m.process(line)

        if result:
            break
    return result



figs_matchers = (
    Matcher(r'\s*#\+BEGIN_SRC\s+latex\s+.*:tangle ([-_.a-zA-Z0-9]+)', first_group),
)

def scan_figs_file(figs):
    deps = set()
    with open(figs) as f:
        for l in f:
            path = process_line(l, figs_matchers)
            if path:
                deps.add(os.path.join('$(builddir)', path))
    return deps

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('file', help='input file')
    parser.add_argument("-o", "--out", help="output file")

    args = parser.parse_args()
    input_file = args.file
    output_file = args.out
    intermediate = "{}.intermediate".format(input_file)

    deps = scan_figs_file(input_file)
    with open(output_file, 'w') as f:
        f.write('{}: {}\n\n'.format(output_file, input_file))
        f.write('{}: \\\n'.format(' \\\n'.join(deps)))
        f.write('\t{}\n\n'.format(intermediate))
        f.write('\n.INTERMEDIATE: {}\n'.format(intermediate))
        f.write('{}: {}\n'.format(intermediate, input_file))
        f.write('\t$(EMACS) $(emacs_loads) --visit=$< $(tangle)\n')
