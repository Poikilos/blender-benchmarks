#!/usr/bin/env python
import sys
import os
from datetime import datetime

__doc__ = '''
Get the date for the newest file recursively, excluding .git or .svn
directories.

Command:
newest.py <filename> [<options>]

Options:
--verbose             List the most recent files in a YAML list named
                      "most_recent:"
--only-ext=<value>    Only get the date where the file extension matches
                      <value> (case insensitive).
'''

def anyIsIn(haystack, needles):
    for needle in needles:
        if needle in haystack:
            return True
    return False


class NewestInfo:
    def __init__(self, ts, p):
        '''
        Sequential arguments:
        ts -- timestamp
        p -- path
        '''
        self.ts = ts
        self.p = p


def error(*args):
    msg = ""
    pre = ""
    for arg in args:
        msg = pre + str(arg)
        pre = " "
    sys.stderr.write(msg + "\n")


def usage():
    error()
    error("Usage:")
    error(__doc__)
    error()


def main(args):
    if len(args) < 2:
        raise ValueError("You must specify a directory.")
    parent = args[1]
    if not os.path.isdir(parent):
        raise ValueError("\"{}\" is not a directory.".format(parent))
    verbose = False
    onlyDotExt = None
    for i in range(2, len(args)):
        arg = args[i]
        if arg == "--verbose":
            verbose = True
        elif arg.startswith("--only-ext="):
            onlyDotExt = "." + arg[len("--only-ext="):].lower()
        else:
            usage()
            raise ValueError("Unknown option: {}".format(arg))
    latest = []
    rawSkips = ['.svn', '.git']
    skips = [os.sep + s + os.sep for s in rawSkips]
    maxCount = 10
    for root, dirs, files in os.walk(parent, topdown=False):
        for name in files:
            subPath = os.path.join(root, name)
            if anyIsIn(subPath, skips):
                # error('skipped "{}"'.format(subPath))
                continue
            # error('checking: "{}"'.format(subPath))
            if onlyDotExt is not None:
                if not name.lower().endswith(onlyDotExt):
                    continue
            ts = os.path.getmtime(subPath)
            if (len(latest) < 1):
                latest.append(NewestInfo(ts, subPath))
            elif ts > latest[-1].ts:
                latest.append(NewestInfo(ts, subPath))
            else:
                latest = [NewestInfo(ts, subPath)] + latest
            if len(latest) > maxCount:
                latest = latest[len(latest)-maxCount:]
    if verbose:
        print("most_recent:")
        for info in latest:
            print("-")
            print("  path: {}".format(info.p))
            ts = info.ts
            t = datetime.utcfromtimestamp(ts).strftime('%Y-%m-%d %H:%M:%S')
            print("  time: {}".format(t))
    else:
        if len(latest) > 0:
            print(latest[-1].ts)
        # else standard output should be blank.

if __name__ == "__main__":
    try:
        main(sys.argv)
    except ValueError as ex:
        error("Error:")
        error(str(ex))
