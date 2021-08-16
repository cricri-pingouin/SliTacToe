# SliTacToe
A Tic Tac Toe game, 2 players or 1 player vs CPU. Written in Turbo Delphi. AI is as you'd expect: first try centre, second search for self winning move, third search for opponent human winning move to block, and if all fail, plays randomly.

----------------
v1.1, 16/08/2021
----------------
CPU now has 4 levels of strength to choose from.
- Level 1: plays randomly throughout the game
- Level 2: will play for win if it can win at the current move, and block a user win if user has a winning move, otherwise plays randomly
- Level 3: as level 2 but will first play centre if available (which can only happen on CPU first move obviously)
- Level 4: as level 3 but if none of the scenarios listed above apply, will favour an available corner (level 3 would play randomly and not favour a corner over a side)

CPU level is saved in a .ini file on exit. If .ini not present on load, will default to level 1.
