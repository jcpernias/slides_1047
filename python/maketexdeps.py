#!/usr/bin/env python3

import argparse
import re
import os
import os.path

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



def handle_figure(m):
    name = m.group(1)
    if len(os.path.dirname(name)) != 0:
        return name
    ext = os.path.splitext(name)[1]
    if ext == ".pdf":
        folder = "figures"
    else:
        folder = "img"
    path = os.path.join(folder, name)
    return path

def handle_tex(m):
    path = '{}.tex'.format(m.group(1))
    return os.path.relpath(path)



tex_matchers = (
    Matcher(r'^[^%]*\\includegraphics(?:\[[^]]*\])?\{([^}]+)\}', handle_figure),
    Matcher(r'^[^%]*\\input\{([^}]+)\}', handle_tex)
)

lang_re = re.compile(r'\\LANG')
file_re = re.compile(r'-([a-z]{2})\.')

def scan_tex_file(tex):
    lang = None
    m  = file_re.search(tex)
    if m:
        lang = m.group(1)

    deps = set()
    with open(tex) as f:
        for l in f:
            path = process_line(l, tex_matchers)
            if path:
                if lang:
                    path = lang_re.sub(lang, path)
                deps.add(path)
    return deps

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('file', help='input file')
    parser.add_argument("-o", "--out", help="output file")
    parser.add_argument("-t", "--target", help="target file")

    args = parser.parse_args()
    input_file = args.file
    output_file = args.out
    target_file = args.target

    tracker = Tracker()
    figures = set()

    f = input_file
    while f:
        ext = os.path.splitext(f)[1]
        if ext == ".tex":
            new_deps = scan_tex_file(f)
            tracker.add(new_deps)
        elif ext == ".pdf":
            figures.add(f)
        f = tracker.pop()

    deps = tracker.tracked()

    with open(output_file, 'w') as f:
        f.write('{}: {}\n\n'.format(output_file, input_file))
        f.write('{}: \\\n'.format(target_file))
        f.write('\t{}'.format(' \\\n\t'.join(deps)))
        f.write('\n\n')

        if len(figures):
            f.write('FIGURES +=\\\n')
            f.write('\t{}'.format(' \\\n\t'.join(figures)))
            f.write('\n\n')

        # f.write(''.join([d + ':\n' for d in deps]))
