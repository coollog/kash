import math
import os
import random
import sys


def main():
  filename = sys.argv[1]

  run_trials(filename)


def run_trials(filename):
  hits = 0
  total = 0
  while True:
    for i in range(1000*1000):
      total += 1

      x = random.random()
      y = random.random()
      if math.sqrt(x * x + y * y) < 1.0:
        hits += 1

    with open(filename + ".tmp", "w") as file:
      file.write(str(hits) + "\n" + str(total))
      file.flush()
      os.fsync(file.fileno())

    os.rename(filename + ".tmp", filename)


if __name__ == '__main__':
  main()
