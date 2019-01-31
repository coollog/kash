import sys
from os import listdir
from os.path import isfile, join
from time import sleep


def main():
  directory = sys.argv[1]

  display_pi(directory)


def display_pi(directory):
  print("waiting...")

  prev_total = 0

  while True:
    hits = 0
    total = 0

    for filename in listdir(directory):
      if filename.endswith(".tmp"):
        continue
      filename = join(directory, filename)
      if not isfile(filename):
        continue
      with open(filename) as file:
        hits += int(file.readline())
        total += int(file.readline())

    if total > prev_total:
      print("PI = " + str(4 * hits / total) + "(total=" + str(total) + ")")
      prev_total = total

    sleep(0.1)


if __name__ == '__main__':
  main()
