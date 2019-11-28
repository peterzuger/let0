#!/usr/bin/env python
import sys
import json

if __name__ == '__main__':
    with open(sys.argv[1]) as f:
        j = json.loads(f.read())
        args = sys.argv[2:]
        for i in args:
            if isinstance(j, list):
                j = j[int(i)]
            else:
                j = j[i]
        print(j)
