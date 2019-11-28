#!/usr/bin/env python
import sys
import json

def main():
    with open(sys.argv[1]) as f:
        j = json.loads(f.read())
        args = sys.argv[2:]
        for i in args:
            try:
                if isinstance(j, list):
                    j = j[int(i)]
                else:
                    j = j[i]
            except KeyError:
                return None
        return j

if __name__ == '__main__':
    print(main())
