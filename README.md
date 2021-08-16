# SliTacToe
A Tic Tac Toe game, 2 players or 1 player vs CPU. Written in Turbo Delphi. AI is as you'd expect: first try centre, second search for self winning move, third search for opponent human winning move to block, and if all fail, plays randomly.

----------------
v1.1, 16/08/2021
----------------
CPU now has 4 levels of strength to choose from.
Level 1: plays randomly
Level 2: will play for win if it can, and block a user win, otherwise plays randomly
Level 3: as level 2 but will play centre if available
Level 4: as level 3 but will play centre then favour corners if available

CPU level is saved in a .ini file. If not present, will default to level 1.
