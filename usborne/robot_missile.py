# Originally from pp 4-5 of Computer Battlegames
#
# This version in Python (c) 2016 Joe Haig and is released under the
# Beer-Ware License. See the LICENSE file for details.
#
# The original code in BASIC and the associated documentation remain
# (c) 1982 Usborn Publishing Ltd.

from string import ascii_lowercase
from random import choice

print("Robot Missile")
print()
print("Type the correct code")
print("letter (a-z) to")
print("defuse the missile.")
print("You have 4 chances.")
print()

c = choice(ascii_lowercase)
i = ascii_lowercase.index(c)

win = False
for g in range(4):
    guess = input()
    j = ascii_lowercase.index(guess)
    if i == j:
        win = True
        break
    if j < i:
        print("Later", end='')
    if j > i:
        print("Earlier", end='')
    print(" than", guess)

if win:
    print("Tick...Fzzzz...Click...")
    print("You did it")
else:
    print()
    print("BOOOOOOOMMM...")
    print("You blew it.")
    print("The correct code was", c)
