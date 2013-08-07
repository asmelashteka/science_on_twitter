#!/usr/bin/env python

from itertools import tee, isilce

def ngrams(lst, n):
  tlst = lst
  while True:
    a, b = tee(tlst)
    l = tuple(islice(a, n))
    if len(l) == n:
      yield l
      next(b)
      tlst = b
    else:
      break

def main():


if __name__ = '__main__':
   main()
